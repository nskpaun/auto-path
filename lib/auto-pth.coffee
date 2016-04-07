AutoPthView = require './auto-pth-view'
{CompositeDisposable, Point, Range} = require 'atom'

module.exports = AutoPth =
  autoPthView: null
  modalPanel: null
  subscriptions: null

  activate: (state) ->
    @autoPthView = new AutoPthView(state.autoPthViewState)
    @modalPanel = atom.workspace.addModalPanel(item: @autoPthView.getElement(), visible: false)

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that transforms this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'auto-pth:transform': => @transform()

  deactivate: ->
    @modalPanel.destroy()
    @subscriptions.dispose()
    @autoPthView.destroy()

  serialize: ->
    autoPthViewState: @autoPthView.serialize()

  transform: ->
    if editor = atom.workspace.getActiveTextEditor()
      for range in editor.getSelectedBufferRanges()
        line = range.start.row;
        endColumn = range.end.column;
        startColumn = range.start.column;
        lineText = editor.lineTextForBufferRow(line);
        endPoint = new Point(line, lineText.length - 1)
        replaceRange = new Range(new Point(line, endColumn), endPoint);

        editor.scanInBufferRange(new RegExp('\\.', 'g'), replaceRange, (result) ->
          result.replace('\',\'');
        )

        editor.setCursorScreenPosition(range.start);

        editor.moveToBeginningOfLine();
        editor.moveRight(range.end.column);
        editor.delete();
        editor.delete();
        editor.insertText(', [');

        lineText = editor.lineTextForBufferRow(line);
        endPoint = new Point(line, lineText.length - 1)
        replaceRange = new Range(new Point(0, 0), endPoint);
        editor.backwardsScanInBufferRange(new RegExp('[a-zA-Z0-9]', 'g'), replaceRange, (result) ->
          result.replace(result.matchText + '\'])');
          result.stop();
        )

        editor.moveToBeginningOfLine();
        editor.moveRight(startColumn);
        editor.insertText('pth(');
