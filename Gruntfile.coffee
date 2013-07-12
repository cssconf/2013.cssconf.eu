module.exports = (grunt) ->

  hash = ''
  shortHash = ''
  targetDirectory = 'dist'

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
      dist:
        expand: true
        cwd: 'static/img'
        src: ['**']
        dest: 'tmp/static/img'
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
        command: () -> ['sed \'s/{hash}/', shortHash, '/\' _config.yml.default > _config.yml'].join('')
      gitGhPages:
        command: 'git checkout gh-pages'
      gitMaster:
        command: 'git checkout master'
      gitRebaseMaster:
        command: 'git rebase master'
      gitAddNewAssets:
        command: () -> ['git add -A ', targetDirectory, ' && git add __config.yml'].join('')
      gitCommit:
        command: () -> ['git commit -m "deployment: ', hash, '"'].join('')
      gitPush:
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

  grunt.registerTask 'git-prepare', [
    'shell:gitGhPages'
    'shell:gitRebaseMaster'
  ]

  grunt.registerTask 'git-finalize', [
    'shell:gitAddNewAssets'
    'shell:gitCommit'
    'shell:gitPush'
    'shell:gitMaster'
  ]

  grunt.registerTask 'deploy', [
    'git-prepare'
    'build-assets'
    'git-finalize'
  ]
