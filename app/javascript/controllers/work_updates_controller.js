import { Controller } from "stimulus"
import consumer from '../channels/consumer'

export default class extends Controller {
  static targets = ['state', 'purl', 'citation']

  connect() {
    let workUpdatesController = this

    this.subscription = consumer.subscriptions.create(
      {
        channel: 'WorkUpdatesChannel',
        workId: this.data.get('workId')
      },
      {
        connected() {
          // Called when the subscription is ready for use on the server
        },
        disconnected() {
          // Called when the subscription has been terminated by the server
        },
        received(data) {
          // Called when there's incoming data on the websocket for this channel
          workUpdatesController.renderUpdates(data)
        }
      }
    )
  }

  disconnect() {
    this.subscription.unsubscribe()
  }

  renderUpdates(data) {
    for (const [attribute, value] of Object.entries(data)) {
      const target = this.targets.find(attribute)
      target.innerHTML = value
    }
  }
}
