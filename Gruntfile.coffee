module.exports = (grunt) ->

  hash = ''
  shortHash = ''
  targetDirectory = 'cdn'

  grunt.initConfig {
    pkg: grunt.file.readJSON('package.json')

    clean: [targetDirectory]

    compass:
      dist:
        options:
          sassDir: 'static/css/sass'
          cssDir: 'tmp/static/css'
          environment: 'production'

    copy:
      img:
        expand: true
        cwd: 'static/img'
        src: ['**']
        dest: 'tmp/static/img'
        filter: 'isFile'
      fonts:
        expand: true
        cwd: 'static/fonts'
        src: ['**']
        dest: 'tmp/static/fonts'
        filter: 'isFile'

    shell:
      chash:
        command: 'git log --pretty=format:\'%H\' -n 1'
        options:
          callback: (err, stdout, stderr, cb) ->
            hash = stdout
            shortHash = hash.substr(0,7)
            cb()
      moveFiles:
        command: () -> ['mkdir ', targetDirectory, ' && mv tmp ', targetDirectory, '/', shortHash].join('')
      config:
        command: () -> ['sed \'s/{uniqueTarget}/', targetDirectory, '\\/', shortHash, '/\' _config.yml.default > _config.yml'].join('')
      gitGhPages:
        command: 'git checkout gh-pages'
      gitMaster:
        command: 'git checkout master'
      gitUpdateMaster:
        command: 'git pull --rebase'
      gitRebaseMaster:
        command: 'git rebase master'
      gitAddNewAssets:
        command: () -> ['git add -A ', targetDirectory, ' && git add _config.yml'].join('')
      gitCommit:
        command: () -> ['git commit -m "deployment: ', hash, '"'].join('')
      gitPushMaster:
        command: 'git push origin master'
      gitPushGhPages:
        command: 'git push origin gh-pages'

  }

  grunt.loadNpmTasks 'grunt-shell'
  grunt.loadNpmTasks 'grunt-contrib-clean'
  grunt.loadNpmTasks 'grunt-contrib-compass'
  grunt.loadNpmTasks 'grunt-contrib-copy'

  grunt.registerTask 'build-assets', [
    'clean'
    'shell:chash'
    'compass'
    'copy'
    'shell:moveFiles'
    'shell:config'
  ]

  grunt.registerTask 'deploy', [
    'shell:gitMaster'
    'shell:gitUpdateMaster'
    'build-assets'
    'shell:gitAddNewAssets'
    'shell:gitCommit'
    'shell:gitPushMaster'
    'shell:gitGhPages'
    'shell:gitRebaseMaster'
    'shell:gitPushGhPages'
  ]
