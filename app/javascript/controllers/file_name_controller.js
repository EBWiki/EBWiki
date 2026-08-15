import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['input', 'display']

  browse(event) {
    event.preventDefault()
    this.inputTarget.click()
  }

  changed() {
    const file = this.inputTarget.files?.[0]
    if (file && this.hasDisplayTarget) {
      this.displayTarget.value = file.name
    }
  }
}
