import { Controller } from "@hotwired/stimulus"

// Placeholder for cocoon migration; cocoon JS remains loaded until S1b follow-up.
export default class extends Controller {
  static targets = ["template", "container"]

  add(event) {
    event.preventDefault()
    if (!this.hasTemplateTarget || !this.hasContainerTarget) return

    const content = this.templateTarget.innerHTML.replace(/NEW_RECORD/g, new Date().getTime())
    this.containerTarget.insertAdjacentHTML("beforeend", content)
  }

  remove(event) {
    event.preventDefault()
    const wrapper = event.target.closest("[data-nested-form-item]")
    if (wrapper) wrapper.remove()
  }
}
