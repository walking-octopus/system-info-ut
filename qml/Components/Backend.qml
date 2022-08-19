import QtQuick 2.12
import io.thp.pyotherside 1.4

Python {
    id: python

    signal ready()

    Component.onCompleted: {
        addImportPath(Qt.resolvedUrl('../../src/'));

        importModule('system_info', function() {
            ready();
        });
    }

    onError: {
        print(`Python error: ${traceback}`);
        // error(i18n.tr("Unknown error. View the logs for more info."));
    }
}