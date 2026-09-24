// Renders assets/icon/*.svg to PNG with headless Chromium (playwright-core).
//   node tool/icon/render.js
const { chromium } = require('playwright-core');
const fs = require('fs');
const path = require('path');

const dir = path.join(__dirname, '..', '..', 'assets', 'icon');
const jobs = [
  ['icon.svg', 'icon.png', 1024, false],
  ['icon.svg', 'app_icon_256.png', 256, false],
  ['icon_foreground.svg', 'icon_foreground.png', 1024, true],
  ['icon_background.svg', 'icon_background.png', 1024, false],
];

(async () => {
  const browser = await chromium.launch({
    executablePath: process.env.CHROMIUM || '/opt/pw-browsers/chromium',
  });
  for (const [src, out, size, transparent] of jobs) {
    const page = await browser.newPage({ viewport: { width: size, height: size } });
    const svg = fs.readFileSync(path.join(dir, src), 'utf8');
    await page.setContent(
      `<html><body style="margin:0;background:transparent">` +
      svg.replace('<svg ', `<svg width="${size}" height="${size}" `) +
      `</body></html>`);
    await page.screenshot({ path: path.join(dir, out), omitBackground: transparent });
    await page.close();
    console.log('rendered', out);
  }
  await browser.close();
})();
