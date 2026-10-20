import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["fileInput", "displayInput"]

  browse(event) {
    event.preventDefault()
    this.fileInputTarget.click()
  }

  updateDisplay() {
    const path = this.fileInputTarget.value
    if (!path) return

    const segments = path.split(/[/\\]/)
    this.displayInputTarget.value = segments[segments.length - 1]
  }
}
