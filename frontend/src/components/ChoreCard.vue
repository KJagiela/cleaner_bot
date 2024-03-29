<template>
  <q-btn
    class="chore"
    @click="setDone()"
    :class="`chore-${choreStatus}`"
  >
    {{ chore.name }} <br><br>
    <div v-if="bigScreen">
      {{ choreComment() }}
    </div>
    <div v-else>
      {{ chore.due_date }}
    </div>
  </q-btn>
</template>

<script setup>
import { ref } from 'vue'
import { useQuasar } from 'quasar'
import { api } from 'boot/axios'

const props = defineProps(['chore'])
const emit = defineEmits(['choreUpdated'])
const chore = ref(props.chore)
const choreStatus = ref(chore.value.status)

const $q = useQuasar()
let cancelled = false

function setDone () {
  choreStatus.value = 'safe'
  $q.notify({
    message: 'Marking as done...',
    icon: 'cloud_done',
    actions: [
      {
        label: 'Cancel',
        color: 'white',
        handler: () => {
          choreStatus.value = chore.value.status
          cancelled = true
        }
      }
    ]
  })
  setTimeout(callMarkDone, 2000)
}

function choreComment () {
  if ((chore.value.status === 'safe') || (chore.value.status === 'soon')) {
    return `Should be done at ${chore.value.due_date}`
  }
  return `Should've been done before ${chore.value.due_date}`
}

function callMarkDone () {
  if (cancelled) {
    return
  }
  api.post(
    'chores/mark_done/',
    { chore_id: chore.value.id }
  )
    .then((resp) => {
      choreStatus.value = 'safe'
      chore.value = resp.data
      emit('choreUpdated')
    }
    )
    .catch((error) => {
      const errorMessages = Object.values(error.response.data).join(',')
      $q.notify(
        { message: `Could not mark as done: ${errorMessages}` }
      )
    })
}

const bigScreen = window.innerWidth > 600
</script>
