import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15 as QQC2
import QtGraphicalEffects 1.15

import common 1.0
import pages 1.0
import io.github.zanyxdev.nova8 1.0
import io.github.zanyxdev.nova8.hal 1.0
import io.github.zanyxdev.nova8.engine 1.0

QQC2.ApplicationWindow {
  id: appWnd

  // ----- Property Declarations
  // Required properties should be at the top.
  readonly property int screenOrientation: Qt.LandscapeOrientation
  readonly property bool appInForeground: Qt.application.state === Qt.ApplicationActive
  property var screenWidth: Screen.width
  property var screenHeight: Screen.height
  property var screenAvailableWidth: Screen.desktopAvailableWidth
  property var screenAvailableHeight: Screen.desktopAvailableHeight
  // ----- Signal declarations

  // ----- Size information
  width: (screenOrientation === Qt.PortraitOrientation) ? 360 : 640
  height: (screenOrientation === Qt.PortraitOrientation) ? 640 : 360
  maximumHeight: height
  maximumWidth: width

  minimumHeight: height
  minimumWidth: width

  // ----- Then comes the other properties. There's no predefined order to these.
  visible: true
  visibility: (isMobile) ? Window.FullScreen : Window.Windowed
  flags: Qt.Dialog

  title: (isMobile) ? qsTr(" ") : Qt.application.name
  onAppInForegroundChanged: {
    AppSingleton.toLog(`appInForeground: [${appInForeground}] Qt.application.version ${Qt.application.version}`)
    if (appInForeground) {

      //paused
    } else {

      //played
    }
  }

  // ----- Signal handlers
  // ----- Qt provided visual children
  background: Rectangle {
    id: background
    anchors.fill: parent
    color: "lightgrey"
    Rectangle {
      id: borderRect
      anchors.fill: parent
      color: "transparent"
      border.color: "black"
      border.width: 4
      radius: 8
    }
  }

  RowLayout {
    id: main
    anchors.fill: parent
    spacing: 4
    Item {
      Layout.fillHeight: true
      Layout.preferredWidth: 10
    }

    Rectangle {
      id: virtDpad
      Layout.fillHeight: true
      Layout.topMargin: 10
      Layout.bottomMargin: 10
      Layout.preferredWidth: 150
      Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter

      color: "transparent"
      border {
        color: "brown"
        width: 4
      }
      radius: 8
    }
    ColumnLayout {
      id: centralPlace
      spacing: 4
      Layout.fillHeight: true
      Layout.fillWidth: true

      QQC2.Label {
        id: titleText

        Layout.fillWidth: true
        Layout.preferredHeight: 36

        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        wrapMode: Text.NoWrap
        font {
          family: AppSingleton.digitalFont.name
          pointSize: AppSingleton.averageFontSize
        }
        color: "darkblue"
        text: qsTr("Fancy CHIP-8")
      }
      Rectangle {
        id: virtScreen
        Layout.preferredWidth: 256
        Layout.preferredHeight: 256
        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
        color: "transparent"
        border {
          color: "black"
          width: 4
        }
        radius: 8
      }
      QQC2.RoundButton {
        id: startButton
        font {
          family: AppSingleton.digitalFont.name
          pointSize: AppSingleton.smallFontSize
        }
        width: 100
        height: 100
        radius: width / 2 // Makes it perfectly circular
        text: qsTr("Start")
        onClicked: {
          console.log("Round button clicked!")
        }

        layer.enabled: true
        layer.effect: Glow {
          samples: 10
          radius: 8
          spread: 0.5
          color: "red"
          transparentBorder: true
        }
      }
      Item {
        Layout.fillWidth: true
        Layout.preferredHeight: 2
      }
    }

    Rectangle {
      id: virtKeyb
      Layout.fillHeight: true
      Layout.topMargin: 10
      Layout.bottomMargin: 10
      Layout.preferredWidth: 180
      Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter

      color: "transparent"
      border {
        color: "brown"
        width: 4
      }
      radius: 8
    }
    Item {
      Layout.fillHeight: true
      Layout.preferredWidth: 10
    }
  }


  /**
  ColumnLayout {
    id: main
    visible: false
    enabled: false
    anchors.fill: parent
    spacing: 4

    // Статус бар
    Image {
      id: statusBarImg
      Layout.preferredWidth: 128 * ENGINE.scale
      Layout.preferredHeight: 16 * ENGINE.scale
      Layout.alignment: Qt.AlignHCenter
      source: "image://virtual_screen/128x16/statusbar"
      fillMode: Image.PreserveAspectFit
    }


    QQC2.Button {
      id: selectChip8
      Layout.preferredWidth: 72
      Layout.preferredHeight: 72
      text: "CHIP-8"
      onClicked: {
        ENGINE.devType = 1
      }
    }
    QQC2.Button {
      id: selectNova8
      Layout.preferredWidth: 72
      Layout.preferredHeight: 72
      text: "NOVA-8"
      onClicked: {
        ENGINE.devType = 2
      }
    }
  }
 */
  // ----- Qt provided non-visual children

  // ----- Custom non-visual children
  Component.onCompleted: {
    if (!isMobile) {
      appWnd.moveToCenter()
    }
  }

  // ----- JavaScript functions
  function moveToCenter() {
    appWnd.y = (screenAvailableHeight / 2) - (height / 2)
    appWnd.x = (screenAvailableWidth / 2) - (width / 2)
  }
}
