/// GHS/CLP hazard statements that appear in the CHEM21 tables, with their
/// standard English wording and the Turkish wording of the CLP (SEA)
/// regulation.
library;

const hStatements = <String, ({String en, String tr})>{
  'H301': (en: 'Toxic if swallowed', tr: 'Yutulması halinde toksiktir'),
  'H302': (en: 'Harmful if swallowed', tr: 'Yutulması halinde zararlıdır'),
  'H304': (
    en: 'May be fatal if swallowed and enters airways',
    tr: 'Yutulması ve solunum yollarına nüfuz etmesi halinde öldürücü olabilir',
  ),
  'H312': (
    en: 'Harmful in contact with skin',
    tr: 'Cilt ile teması halinde zararlıdır',
  ),
  'H314': (
    en: 'Causes severe skin burns and eye damage',
    tr: 'Ciddi cilt yanıklarına ve göz hasarına yol açar',
  ),
  'H315': (en: 'Causes skin irritation', tr: 'Cilt tahrişine yol açar'),
  'H318': (en: 'Causes serious eye damage', tr: 'Ciddi göz hasarına yol açar'),
  'H319': (
    en: 'Causes serious eye irritation',
    tr: 'Ciddi göz tahrişine yol açar',
  ),
  'H332': (en: 'Harmful if inhaled', tr: 'Solunması halinde zararlıdır'),
  'H336': (
    en: 'May cause drowsiness or dizziness',
    tr: 'Rehavete veya baş dönmesine yol açabilir',
  ),
  'H350': (en: 'May cause cancer', tr: 'Kansere yol açabilir'),
  'H351': (
    en: 'Suspected of causing cancer',
    tr: 'Kansere yol açma şüphesi var',
  ),
  'H360': (
    en: 'May damage fertility or the unborn child',
    tr: 'Üremeye veya doğmamış çocuğa zarar verebilir',
  ),
  'H361': (
    en: 'Suspected of damaging fertility or the unborn child',
    tr: 'Üremeye veya doğmamış çocuğa zarar verme şüphesi var',
  ),
  'H400': (en: 'Very toxic to aquatic life', tr: 'Sucul ortamda çok toksiktir'),
  'H410': (
    en: 'Very toxic to aquatic life with long lasting effects',
    tr: 'Sucul ortamda uzun süre kalıcı, çok toksik etki',
  ),
  'H411': (
    en: 'Toxic to aquatic life with long lasting effects',
    tr: 'Sucul ortamda uzun süre kalıcı, toksik etki',
  ),
  'H412': (
    en: 'Harmful to aquatic life with long lasting effects',
    tr: 'Sucul ortamda uzun süre kalıcı, zararlı etki',
  ),
  'H420': (
    en:
        'Harms public health and the environment by destroying ozone in the '
        'upper atmosphere',
    tr:
        'Üst atmosferdeki ozonu tahrip ederek halk sağlığına ve çevreye zarar '
        'verir',
  ),
};
