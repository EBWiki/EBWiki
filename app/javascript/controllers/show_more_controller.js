import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['item']
  static values = { limit: { type: Number, default: 10 } }

  connect() {
    this.expanded = false
    if (this.itemTargets.length <= this.limitValue) return

    this.collapse()
    this.toggleButton = document.createElement('li')
    this.toggleButton.className = 'more btn btn-sm btn-outline-secondary'
    this.toggleButton.innerHTML = '<a href="#">Show more</a>'
    this.toggleButton.addEventListener('click', this.toggle)
    this.element.appendChild(this.toggleButton)
  }

  disconnect() {
    if (this.toggleButton) {
      this.toggleButton.removeEventListener('click', this.toggle)
    }
  }

  toggle = (event) => {
    event.preventDefault()
    this.expanded = !this.expanded
    if (this.expanded) {
      this.itemTargets.forEach((el) => { el.hidden = false })
      this.toggleButton.querySelector('a').textContent = 'Show less'
    } else {
      this.collapse()
      this.toggleButton.querySelector('a').textContent = 'Show more'
    }
  }

  collapse() {
    this.itemTargets.forEach((el, index) => {
      el.hidden = index >= this.limitValue
    })
  }
}
