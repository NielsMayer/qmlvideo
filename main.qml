// Copyright (C) 2019 Niels P. Mayer (http://nielsmayer.com)
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

import QtQuick 2.12;
import QtQuick.Controls 2.12;
import QtQuick.Layouts 1.12;
import QtMultimedia 5.12;

ApplicationWindow {
    id:                              app;
    title:                           qsTr("Video Bug Demo -- Click/Space to Pause/Play!");
    visible:                         true;
    width:                           640;
    height:                          480;

    footer: ToolBar {
        RowLayout {
            anchors.fill:            parent;
            ToolButton {
                text:                qsTr("Quit");
                onClicked:           Qt.quit();
                highlighted:         true;
            }
            Label {
                text:                (video.media_info)                 //replace initial "loading video" with metadata from media, once video loaded.
                                        ? ((video.is_playing) ? qsTr("Playing: ") : qsTr("Paused: "))
                                            + video.media_info
                                        : qsTr("... Loading Video ...");  //BUG: on Android, this message never goes away because metaData.* remains undefined.
                elide:               Label.ElideRight;
                horizontalAlignment: Qt.AlignHCenter;
                verticalAlignment:   Qt.AlignVCenter;
                Layout.fillWidth:    true;
            }
            ToolButton {
                text:                ((video.is_playing) ? qsTr("Pause") : qsTr("Play"));
                onClicked:           video.play_pause();
            }
        }
    }

    Video {
        id:                          video;
        source:                      "https://www.radiantmediaplayer.com/media/bbb-360p.mp4";
        anchors.fill:                parent;
        autoPlay:                    true;
        MouseArea {
            anchors.fill:            parent;
            onClicked:               video.play_pause();
        }
        focus:                       true;
        Keys.onSpacePressed:         video.play_pause();
        Keys.onUpPressed:            video.seek(video.position - 10000);
        Keys.onDownPressed:          video.seek(video.position + 10000);
        Keys.onLeftPressed:          video.seek(video.position - 1000);
        Keys.onRightPressed:         video.seek(video.position + 1000);

        function play_pause() {
            if (is_playing)
                video.pause();
            else
                video.play();
        }

        audioRole: (hasVideo)
                   ? MediaPlayer.VideoRole
                   : MediaPlayer.MusicRole;

        readonly property bool is_playing:
            (playbackState === MediaPlayer.PlayingState)

        readonly property string media_info:
            (hasVideo) // video case
            ? (((typeof(metaData.videoCodec) === "string") && (typeof(metaData.videoBitRate) === "number"))
               ? qsTr("%1 - %L2kb/s").arg(metaData.videoCodec).arg((metaData.videoBitRate/1000).toFixed(0))
               : (typeof(metaData.videoCodec) === "string")
                 ? qsTr("%1").arg(metaData.videoCodec)
                 : ""
                   || (typeof(metaData.videoBitRate) === "number")
                   ? qsTr("%L1kb/s").arg((metaData.videoBitRate/1000).toFixed(0))
                   : "")
            //audio case
            : ((typeof(metaData.audioCodec) === "string") && (typeof(metaData.audioBitRate) === "number"))
              ? qsTr("%1 - %L2kb/s").arg(metaData.audioCodec).arg((metaData.audioBitRate/1000).toFixed(0))
              : (typeof(metaData.audioCodec) === "string")
                ? qsTr("%1").arg(metaData.audioCodec)
                : ""
                  || (typeof(metaData.audioBitRate) === "number")
                  ? qsTr("%L1kb/s").arg((metaData.audioBitRate/1000).toFixed(0))
                  : "";
    }
}

