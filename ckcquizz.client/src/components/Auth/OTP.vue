<template>
  <div ref="otpCont" class="d-flex justify-content-center gap-2 gap-md-3">
    <input
      type="text"
      class="digit-box form-control text-center"
      v-for="(el, ind) in digits"
      :key="el+ind"
      v-model="digits[ind]"
      :autofocus="ind === 0"
      maxlength="1"
      @keydown="handleKeyDown($event, ind)"
      :class="{bounce: digits[ind] !== null}"
    >
  </div>
</template>

<script setup>
  import { ref, reactive } from 'vue';

  const props = defineProps({
    default: String,

    digitCount: {
      type: Number,
      required: true
    }
  });

  const digits = reactive([])

  if (props.default && props.default.length === props.digitCount) {
    for (let i =0; i < props.digitCount; i++) {
      digits[i] = props.default.charAt(i)
    }
  } else {
    for (let i =0; i < props.digitCount; i++) {
      digits[i] = null;
    }
  }

  const otpCont = ref(null)


  const emit = defineEmits(['update:otp']);

  const isDigitsFull = function () {
    for (const elem of digits) {
      if (elem == null || elem == undefined) {
        return false;
      }
    }

    return true;
  }

  const handleKeyDown = function (event, index) {
    if (event.key !== "Tab" && 
        event.key !== "ArrowRight" &&
        event.key !== "ArrowLeft"
    ) {
      event.preventDefault();
    }
    
    if (event.key === "Backspace") {
      digits[index] = null;
      
      if (index != 0) {
        (otpCont.value.children)[index-1].focus();
      } 

      return;
    }

    if ((new RegExp('^([0-9])$')).test(event.key)) {
      digits[index] = event.key;

      if (index != props.digitCount - 1) {
        (otpCont.value.children)[index+1].focus();
      }

      if (isDigitsFull()) {
        emit('update:otp', digits.join(''))
      }
    }
  }

</script>

<style scoped>
.digit-box {
  width: 3.2rem !important; 
  height: 3.8rem !important;
  font-size: 1.6rem;     
  padding-left: 0.25rem !important;
  padding-right: 0.25rem !important;
}
.digit-box:focus {
  outline: 3px solid black;
}

.bounce {
  animation: pulse .3s ease-in-out alternate;
}

@keyframes pulse {
  0% {
    transform: scale(1);
  }

  100% {
    transform: scale(1.1);
  }
}
</style>