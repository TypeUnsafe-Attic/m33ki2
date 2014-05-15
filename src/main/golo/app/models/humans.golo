module models.humans

function Human = |firstName, lastName| {

  return DynamicObject()
    : firstName(firstName)
    : lastName(lastName)
    : define("toString", |this| -> this: firstName() + " " + this: lastName())

}