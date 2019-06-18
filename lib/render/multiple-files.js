$(document).ready(function() {
  const setEditorMainFile = () => {
    const multipleFileEditor = mumuki.multipleFileEditor;
    if(!multipleFileEditor) return setTimeout(setEditorMainFile, 100);
    multipleFileEditor.mainFile = 'index.html';
    multipleFileEditor.updateButtonsVisibility();
  };

  setEditorMainFile();
});
