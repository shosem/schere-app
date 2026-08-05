import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="modal"
export default class extends Controller {
  static targets = [ "modal", "card" ]
  connect() {
  }

  closeModal(e) {
    if(!this.cardTarget.contains(e.target))
      this.modalTarget.innerHTML = ""
  }

  close() {
    this.modalTarget.innerHTML = ""
  }
}
