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
    AppSingleton.toLog(
          `appInForeground: [${appInForeground}] Qt.application.version ${Qt.application.version}`)
    if (appInForeground) {

      //paused
    } else {

      //played
    }
  }

  // ----- Signal handlers
  // ----- Qt provided visual children
  GameEnginePartQml {
    id: gameEngineQmlPart
    RowLayout {
      id: main
      anchors.fill: parent
      spacing: 4
      Item {
        Layout.fillHeight: true
        Layout.preferredWidth: 10
      }
      ColumnLayout {
        id: leftButtonPlace
        spacing: 4
        Layout.fillHeight: true
        Layout.fillWidth: true
        QQC2.Button {
          id: startBtn
          font {
            family: AppSingleton.digitalFont.name
            pointSize: AppSingleton.smallFontSize
          }
          text: "START"
        }
        QQC2.Button {
          id: upBtn
          font {
            family: AppSingleton.digitalFont.name
            pointSize: AppSingleton.smallFontSize
          }
          text: "UP"
          Shortcut {
            sequence: "Up" // Use "Up", "Down", "Left", or "Right"
            onActivated: {
              upBtn.clicked() // Trigger the button's onClicked handler
            }
          }

          onClicked: {
            console.log("Up Arrow pressed!")
          }
        }
        QQC2.Button {
          id: downBtn
          font {
            family: AppSingleton.digitalFont.name
            pointSize: AppSingleton.smallFontSize
          }
          text: "Down"
          Shortcut {
            sequence: "Down" // Use "Up", "Down", "Left", or "Right"
            onActivated: {
              downBtn.clicked() // Trigger the button's onClicked handler
            }
          }

          onClicked: {
            console.log("Down Arrow pressed!")
          }
        }
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
          text: gameEngineQmlPart.currentPressedKeyName //qsTr("Fancy CHIP-8")
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
          ColumnLayout {
            anchors.fill: parent
            id: testLight
            spacing: 2
            Repeater {
              model: gameEngineQmlPart.model
              QQC2.CheckBox {
                text: model.keyName
                checked: model.pressed
              }
            }
          }
        }

        Item {
          Layout.fillWidth: true
          Layout.preferredHeight: 2
        }
      }

      GridLayout {
        id: rightButtonPlace
        Layout.fillHeight: true
        Layout.fillWidth: true
        QQC2.Button {
          id: zeroBtn
          autoRepeat: false
          font {
            family: AppSingleton.digitalFont.name
            pointSize: AppSingleton.smallFontSize
          }
          text: "0"
          onClicked: {
            var currentDate = '[' + new Date().toUTCString() + '] '
            console.log(`${currentDate}:Zero pressed!`)
          }
        }
      }

      Item {
        Layout.fillHeight: true
        Layout.preferredWidth: 10
      }
    }
  }

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
