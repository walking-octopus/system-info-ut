import QtQuick 2.12
import io.thp.pyotherside 1.4
import Ubuntu.Components 1.3

Python {
    id: python

    property bool isLoading
    signal ready()

    function loadCategory(categoryPage, pythonFunction) {
        python.isLoading = true; 
        // Maybe add a Timer to hide the loading bar when the delay is less then half a second?

        python.call(pythonFunction, [], function(systemInfo) {
            python.isLoading = false;
            pStack.push(Qt.resolvedUrl(categoryPage), { "systemInfo": systemInfo });
        });
    }

    function generateReport() {
        python.isLoading = true;

        python.call("system_info.generateReport", [Qt.application.version], function(report) {
            python.isLoading = false;
            Clipboard.push(report);
            toast.show(i18n.tr("Copied a full system info report."))
        });
    }

    Component.onCompleted: {
        addImportPath(Qt.resolvedUrl('../../src/'));

        importModule('system_info', ready());
    }

    onError: {
        print(`Python error: ${traceback}`);
        toast.show(i18n.tr("Critical error. View the logs for more info."));
    }

    onReceived: function(errorIndex) {
        let messageCodes = {
            "AccessDenied": i18n.tr("Access denied.")
        }
        toast.show(messageCodes[errorIndex])
    }
}