import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['template', 'container']

  add(event) {
    event.preventDefault()
    const content = this.templateTarget.innerHTML.replace(/NEW_RECORD/g, new Date().getTime().toString())
    this.containerTarget.insertAdjacentHTML('beforeend', content)
  }

  remove(event) {
    event.preventDefault()
    const fields = event.target.closest('.nested-fields')
    if (!fields) return

    const destroyField = fields.querySelector("input[name*='_destroy']")
    if (destroyField) {
      destroyField.value = '1'
      fields.style.display = 'none'
    } else {
      fields.remove()
    }
  }
}
