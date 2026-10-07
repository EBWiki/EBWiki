import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "counter", "counterContainer"]

  connect() {
    this.update()
  }

  update() {
    const maximumLength = parseInt(this.counterTarget.dataset.maximumLength, 10)
    const currentLength = maximumLength - this.inputTarget.value.length

    this.counterTarget.textContent = currentLength
    if (currentLength < 50) {
      this.counterContainerTarget.classList.add("danger")
    } else {
      this.counterContainerTarget.classList.remove("danger")
    }
  }
}
