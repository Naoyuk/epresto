import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  // connect() {
  //   this.element.textContent = "Hello World!"
  // }
  static targets = ['checkbox']

  greet() {
      console.log("Hello, this order's id is ${id}", this.element)
      this.checkboxTargets.checked
  }
}
