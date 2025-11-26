import QtQuick 2.15
import QtQuick.Layouts 1.15
import common 1.0

StackLayout {
  id: root
  anchors.fill: parent

  property int previousIndex: 0
  property Item previousItem
  property Item currentItem

  Component.onCompleted: {
    previousIndex = currentIndex
    AppSingleton.toLog(`StackLayout.currentIndex [${root.currentIndex}]`)
    AppSingleton.toLog(`StackLayout.count [${root.count}]`)
    for (var i = 1; i < count; ++i) {
      AppSingleton.toLog(`StackLayout.children[i].opacity [${children[i].opacity}]`)

      children[i].opacity = 0
    }
  }

  Component {
    id: crossFader
    ParallelAnimation {
      property Item fadeOutTarget
      property Item fadeInTarget

      NumberAnimation {
        target: fadeOutTarget
        property: "opacity"
        to: 0
        duration: AppSingleton.delay_500
        easing.type: Easing.Linear
      }

      NumberAnimation {
        target: fadeInTarget
        property: "opacity"
        to: 1
        duration: AppSingleton.delay_500
        easing.type: Easing.Linear
      }
    }
  }

  onCurrentIndexChanged: {
    AppSingleton.toLog(`StackLayout.onCurrentIndexChanged [${root.currentIndex}]`)

    previousItem = root.children[previousIndex]
    currentItem = root.children[currentIndex]

    if (previousItem && currentItem && (previousItem != currentItem)) {
      previousItem.visible = true
      currentItem.visible = true
      var crossFaderAnim = crossFader.createObject(parent, {
                                                     "fadeOutTarget": previousItem,
                                                     "fadeInTarget": currentItem
                                                   })
      crossFaderAnim.restart()
    }

    previousIndex = currentIndex
  }
}
