import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['input', 'counter', 'wrapper']
  static values = { max: Number }

  connect() {
    this.update()
  }

  update() {
    const remaining = this.maxValue - (this.inputTarget.value?.length || 0)
    this.counterTarget.textContent = remaining
    this.wrapperTarget.classList.toggle('text-danger', remaining < 50)
  }
}
