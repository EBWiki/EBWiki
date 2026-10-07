import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["item"]
  static values = { threshold: { type: Number, default: 10 } }

  connect() {
    if (this.itemTargets.length <= this.thresholdValue) return

    this.hideBeyondThreshold()
    this.element.appendChild(this.createToggleRow("more", "Show more"))
  }

  handleToggle(event) {
    const link = event.target.closest("[data-show-more-toggle]")
    if (!link || !this.element.contains(link)) return

    event.preventDefault()
    const kind = link.dataset.showMoreToggle

    if (kind === "more") {
      link.remove()
      this.itemTargets.forEach((item) => { item.hidden = false })
      this.element.appendChild(this.createToggleRow("less", "Show less"))
    } else {
      link.remove()
      this.hideBeyondThreshold()
      this.element.appendChild(this.createToggleRow("more", "Show more"))
    }
  }

  hideBeyondThreshold() {
    this.itemTargets.forEach((item, index) => {
      item.hidden = index >= this.thresholdValue
    })
  }

  createToggleRow(kind, label) {
    const li = document.createElement("li")
    li.className = `${kind} btn btn-xs btn-default`
    li.dataset.showMoreToggle = kind

    const anchor = document.createElement("a")
    anchor.href = ""
    anchor.textContent = label
    li.appendChild(anchor)

    return li
  }
}
