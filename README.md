# FinnM0reSPM

## Setup
- Install GitBook

```
$ npm install -g gitbook-cli --save-dev
```

- Run at local

```
$ gitbook install
$ gitbook serve
```

- open [page](http://localhost:4000)

## TroubleShooting

### Can't find `.js` file

```
Error: Couldn't locate plugins "toggle-chapters, splitter, anchor-navigation-ex, prism, copy-code-button, alerts, 
theme-comscore", Run 'gitbook install' to install plugins from registry.

Error: ENOENT: no such file or directory, 
stat 'D:\workspace\core-solution-docs\_book\gitbook\gitbook-plugin-fontsettings\fontsettings.js'

Error: ENOENT: no such file or directory,
stat 'D:\workspace\core-solution-docs\_book\gitbook\gitbook-plugin-livereload\plugin.js'

Error: ENOENT: no such file or directory, 
stat 'D:\workspace\core-solution-docs\_book\gitbook\gitbook-plugin-alerts\plugin.js'

Error: ENOENT: no such file or directory, 
stat 'D:\workspace\core-solution-docs\_book\gitbook\gitbook-plugin-livereload\plugin.js'

Error: ENOENT: no such file or directory, 
stat 'D:\workspace\core-solution-docs\_book\gitbook\gitbook-plugin-search\lunr.min.js'
```

- Open <User>\.gitbook\versions\<version number>\lib\output\website\copyPluginAssets.js

- Change confirm: `true` to `false`

```
function copyResources(output, plugin) {
    var logger = output.getLogger();

    var options    = output.getOptions();
    var outputRoot = options.get('root');

    var state = output.getState();
    var resources = state.getResources();

    var pluginRoot      = plugin.getPath();
    var pluginResources = resources.get(plugin.getName());

    var assetsFolder = pluginResources.get('assets');
    var assetOutputFolder = path.join(outputRoot, 'gitbook', plugin.getNpmID());

    if (!assetsFolder) {
        return Promise();
    }

    // Resolve assets folder
    assetsFolder = path.resolve(pluginRoot, assetsFolder);
    if (!fs.existsSync(assetsFolder)) {
        logger.warn.ln('assets folder for plugin "' + plugin.getName() + '" doesn\'t exist');
        return Promise();
    }

    logger.debug.ln('copy resources from plugin', assetsFolder);

    return fs.copyDir(
        assetsFolder,
        assetOutputFolder,
        {
            deleteFirst: false,
            overwrite: true,
            confirm: false  <---- Change this one
        }
    );
}
```
