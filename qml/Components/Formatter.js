function formatBytes(bytes, decimals = 2) {
    if (bytes === 0) return i18n.tr('Empty');

    const k = 1024;
    const dm = decimals < 0 ? 0 : decimals;
    const sizes = [i18n.tr('Bytes'), 'KB', 'MB', 'GB', 'TB', 'PB', 'EB', 'ZB', 'YB'];

    const i = Math.floor(Math.log(bytes) / Math.log(k));

    return parseFloat((bytes / Math.pow(k, i)).toFixed(dm)) + ' ' + sizes[i];
}