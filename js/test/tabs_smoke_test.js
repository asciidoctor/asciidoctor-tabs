'use strict'

const assert = require('node:assert')
const execFile = require('node:util').promisify(require('node:child_process').execFile)
const { promises: fsp } = require('node:fs')
const os = require('node:os')
const ospath = require('node:path')

const FIXTURES_DIR = ospath.join(__dirname, 'fixtures')
const PACKAGE_DIR = ospath.resolve(__dirname, '..')

describe('tabs smoke test', () => {
  let tmpdir

  before(async () => {
    tmpdir = await fsp.mkdtemp(ospath.join(os.tmpdir(), 'asciidoctor-tabs-'))
  })

  after(async () => {
    await fsp.rm(tmpdir, { recursive: true, force: true })
  })

  it('should generate same output as Ruby extension', async () => {
    const inputPath = ospath.join(FIXTURES_DIR, 'smoke.adoc')
    const scenarios = {
      js: { requirePath: PACKAGE_DIR, baseCommand: ['npx', '--yes'] },
      rb: { requirePath: 'asciidoctor/tabs', baseCommand: ['bundle', 'exec'] },
    }
    const results = {}
    for (const [runtime, { requirePath, baseCommand }] of Object.entries(scenarios)) {
      const outputPath = ospath.join(tmpdir, `${runtime}-smoke.html`)
      const cmd = baseCommand[0]
      const args = baseCommand
        .slice(1)
        .concat('asciidoctor', '-a', 'stylesheet!', '-r', requirePath, '-o', outputPath, inputPath)
      results[runtime] = await execFile(cmd, args)
        .then(() => fsp.readFile(outputPath, 'utf-8'))
        .then((contents) => contents.replace(/<meta name="generator"[^>]*>\n/, ''))
    }
    assert.equal(results.js, results.rb)
  })
})
