module m33ki2.tests

augment java.lang.Object {
  function shouldEqual = |this, value| -> this: equals(value)
  function shouldNotEqual = |this, value| -> not this: equals(value)
  function shouldBeLessThan = |this, value| -> this < value
  function shouldBeLessOrEqualThan = |this, value| -> this <= value
  function shouldBeMoreThan = |this, value| -> this > value
  function shouldBeMoreOrEqualThan = |this, value| -> this >= value
  function shouldBeNull = |this| -> this is null
  function shouldBeNotNull = |this| -> not this is null
}

function specification = |description, requirements| {
  println("Specification : " + description)
  requirements: each(|requirement|{
    requirement()
  })
}

function requirement = |description, closure| {
  println("  Requirement : " + description)
  closure()
}

struct verify  = {
  verbose,
  stop # raise exception if true
}

augment verify {
  function that = |this, assertion| {
    if not assertion {
      if not this: verbose() is false { println("    --> : KO") }
      if this: stop() is true { raise("Huston ? We've got a problem!") }
      return false
    } else {
      if not this: verbose() is false { println("    --> : OK") }
      return true
    }
  }
  function that = |this, message, assertion| {
    if not assertion {
      if not this: verbose() is false { println("    -->" + message + " : KO") }
      if this: stop() is true { raise("Huston ? We've got a problem!") }
      return false
    } else {
      if not this: verbose() is false { println("    --> " + message + " : OK") }
      return true
    }
  }
}


function main = |args| {

  specification("first specs", [
    -> requirement("5 == 5 and 5 != 4", {
        verify(): that(5: shouldEqual(5) and 5: shouldNotEqual(4))
    })
    ,
    -> requirement("Philippe is not Bob", {
        let firstName = "Philippe"
        verify(): that(firstName: shouldNotEqual("Bob"))
    })
    ,
    -> requirement("Oupss...", {
        #verify(): stop(true): that(5: shouldBeLessOrEqualThan(3))
        verify(): that(5: shouldBeLessOrEqualThan(3))
    })
    ,
    -> requirement("Victory!", {
        verify(): that(5: shouldBeLessOrEqualThan(8))
    })
    ,
    -> requirement("Are you Bob Morane ?", {
        let bob = DynamicObject(): firstName("Bob"): lastName("Morane")

        verify(): verbose(false): that("Bob is really Bob ?",
          bob: firstName(): shouldBeNotNull() and
          bob: lastName(): shouldBeNotNull() and
          bob: firstName(): equals("Bob") and
          bob: lastName(): equals("Morane")
        )

        println(verify(): verbose(false): that(5==5))
    })
  ])

  println(verify(): verbose(false): that(5==5))
}