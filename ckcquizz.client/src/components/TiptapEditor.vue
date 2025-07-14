<template>
  <div class="tiptap-editor">
    <div v-if="editor" class="menubar">
      <a-button-group>
        <a-button @click="editor.chain().focus().toggleBold().run()" :disabled="!editor.can().chain().focus().toggleBold().run()" :type="editor.isActive('bold') ? 'primary' : 'default'">
          <Bold />
        </a-button>
        <a-button @click="editor.chain().focus().toggleItalic().run()" :disabled="!editor.can().chain().focus().toggleItalic().run()" :type="editor.isActive('italic') ? 'primary' : 'default'">
          <Italic />
        </a-button>
        <a-button @click="editor.chain().focus().toggleStrike().run()" :disabled="!editor.can().chain().focus().toggleStrike().run()" :type="editor.isActive('strike') ? 'primary' : 'default'">
          <Strikethrough />
        </a-button>
        <a-button @click="editor.chain().focus().toggleCode().run()" :disabled="!editor.can().chain().focus().toggleCode().run()" :type="editor.isActive('code') ? 'primary' : 'default'">
          <Code />
        </a-button>
        <a-button @click="editor.chain().focus().setParagraph().run()" :type="editor.isActive('paragraph') ? 'primary' : 'default'">
          <Pilcrow />
        </a-button>
        <a-button @click="editor.chain().focus().toggleHeading({ level: 1 }).run()" :type="editor.isActive('heading', { level: 1 }) ? 'primary' : 'default'">
          <Heading1 />
        </a-button>
        <a-button @click="editor.chain().focus().toggleHeading({ level: 2 }).run()" :type="editor.isActive('heading', { level: 2 }) ? 'primary' : 'default'">
          <Heading2 />
        </a-button>
        <a-button @click="editor.chain().focus().toggleHeading({ level: 3 }).run()" :type="editor.isActive('heading', { level: 3 }) ? 'primary' : 'default'">
          <Heading3 />
        </a-button>
        <a-button @click="editor.chain().focus().toggleHeading({ level: 4 }).run()" :type="editor.isActive('heading', { level: 4 }) ? 'primary' : 'default'">
          <Heading4 />
        </a-button>
        <a-button @click="editor.chain().focus().toggleBulletList().run()" :type="editor.isActive('bulletList') ? 'primary' : 'default'">
          <List />
        </a-button>
        <a-button @click="editor.chain().focus().toggleOrderedList().run()" :type="editor.isActive('orderedList') ? 'primary' : 'default'">
          <ListOrdered />
        </a-button>
        <a-button @click="editor.chain().focus().toggleCodeBlock().run()" :type="editor.isActive('codeBlock') ? 'primary' : 'default'">
          <CodeSquare />
        </a-button>
        <a-button @click="editor.chain().focus().toggleBlockquote().run()" :type="editor.isActive('blockquote') ? 'primary' : 'default'">
          <Quote />
        </a-button>
        <a-button @click="editor.chain().focus().setHorizontalRule().run()">
          <Minus />
        </a-button>
        <a-button @click="editor.chain().focus().setHardBreak().run()">
          <CornerDownLeft />
        </a-button>
      </a-button-group>

      <a-button-group>
        <a-button @click="editor.chain().focus().unsetAllMarks().run()">
          <RemoveFormatting />
        </a-button>
        <a-button @click="editor.chain().focus().clearNodes().run()">
          <Eraser />
        </a-button>
      </a-button-group>

      <a-button-group>
        <a-button @click="editor.chain().focus().undo().run()" :disabled="!editor.can().chain().focus().undo().run()">
          <Undo />
        </a-button>
        <a-button @click="editor.chain().focus().redo().run()" :disabled="!editor.can().chain().focus().redo().run()">
          <Redo />
        </a-button>
      </a-button-group>
    </div>
    <editor-content :editor="editor" />
  </div>
</template>

<script setup>
import { useEditor, EditorContent } from '@tiptap/vue-3';
import StarterKit from '@tiptap/starter-kit';
import Placeholder from '@tiptap/extension-placeholder';
import { watch, onBeforeUnmount } from 'vue';
import {
  Bold, Italic, Strikethrough, Code, Pilcrow, Heading1, Heading2,
  Heading3, Heading4, List, ListOrdered, CodeSquare, Quote, Minus,
  CornerDownLeft, RemoveFormatting, Eraser, Undo, Redo,
} from 'lucide-vue-next';

const props = defineProps({
  modelValue: {
    type: String,
    default: '',
  },
  placeholder: {
    type: String,
    default: '',
  },
});

const emit = defineEmits(['update:modelValue']);

const editor = useEditor({
  content: props.modelValue,
  extensions: [
    StarterKit,
    Placeholder.configure({
      placeholder: props.placeholder,
    }),
  ],
  editorProps: {
    attributes: {
      class: 'ant-input',
    },
  },
  onUpdate: ({ editor }) => {
    if (editor) {
      emit('update:modelValue', editor.getHTML());
    }
  },
});

watch(() => props.modelValue, (newValue) => {
  if (editor.value && newValue !== editor.value.getHTML()) {
    editor.value.commands.setContent(newValue, false);
  }
});

onBeforeUnmount(() => {
  if (editor.value) {
    editor.value.destroy();
  }
});
</script>

<style lang="scss">
.tiptap-editor {
  border: 1px solid #d9d9d9;
  border-radius: 6px;

  .menubar {
    padding: 8px;
    border-bottom: 1px solid #d9d9d9;
    display: flex;
    flex-wrap: wrap;
    gap: 8px;

    .ant-btn {
      display: inline-flex;
      align-items: center;
      justify-content: center;
      padding: 0 8px;
      min-width: unset;
      height: 32px;
      width: 32px;
    }
  }

  .ProseMirror.ant-input {
    height: auto;
    min-height: 150px;
    padding: 12px;
    outline: none;
    box-shadow: none !important;

    p.is-editor-empty:first-child::before {
      content: attr(data-placeholder);
      float: left;
      color: #adb5bd; 
      pointer-events: none;
      height: 0;
    }

    > * + * {
      margin-top: 0.75em;
    }

    p {
      margin: 0;
    }

    h1, h2, h3, h4, h5, h6 {
      line-height: 1.1;
      font-weight: 600;
    }

    ul, ol {
      padding: 0 1rem;
    }

    code {
      background-color: rgba(97, 97, 97, 0.1);
      color: #616161;
      padding: 0.2em 0.4em;
      border-radius: 5px;
    }

    pre {
      background: #0d0d0d;
      color: #fff;
      font-family: 'JetBrainsMono', monospace;
      padding: 0.75rem 1rem;
      border-radius: 0.5rem;

      code {
        color: inherit;
        padding: 0;
        background: none;
        font-size: 0.8rem;
      }
    }

    blockquote {
      padding-left: 1rem;
      border-left: 3px solid rgba(13, 13, 13, 0.1);
    }

    hr {
      border: none;
      border-top: 2px solid rgba(13, 13, 13, 0.1);
      margin: 1rem 0;
    }
  }
}
</style>