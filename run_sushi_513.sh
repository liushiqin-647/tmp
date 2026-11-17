#!/usr/bin/env bash
# fhir__sushi-513，共 109 条命令，按轨迹原顺序执行
cd /testbed || { echo "缺少 /testbed 目录"; exit 1; }

# [1]
ln -sfn /sushi /testbed && ls /testbed | head -3; go clean -cache 2>/dev/null; rm -rf /testbed/target /testbed/dist /testbed/build /testbed/out /testbed/.gradle /testbed/node_modules/.cache 2>/dev/null; find /testbed -name '__pycache__' -type d -prune -exec rm -rf {} + 2>/dev/null; find /testbed -name '*.tsbuildinfo' -delete 2>/dev/null; find /testbed -name '*.o' -delete 2>/dev/null; true; rm -rf /tmp/jest_* /testbed/node_modules/.vite /testbed/.parcel-cache /testbed/.eslintcache 2>/dev/null; true

# [2]
find /testbed -type f -name "*.js" -o -name "*.ts" | head -20

# [3]
ls -la /testbed

# [4]
grep -r "forEach" /testbed/src --include="*.ts" --include="*.js" | grep -i parameter | head -20

# [5]
find /testbed/src -type f -name "*.ts" | xargs grep -l "Parameters" | head -20

# [6]
find /testbed/src -type f -name "*.ts" | xargs grep -l "Instance" | head -20

# [7]
wc -l /testbed/src/export/InstanceExporter.ts

# [8]
cat /testbed/src/export/InstanceExporter.ts

# [9]
grep -n "forEach" /testbed/src/export/InstanceExporter.ts

# [10]
grep -n "forEach" /testbed/src/fhirtypes/common.ts | head -30

# [11]
sed -n '140,160p' /testbed/src/fhirtypes/common.ts

# [12]
find /testbed/test -type f -name "*.test.ts" | xargs grep -l "Parameters" | head -10

# [13]
find /testbed/test -type f -name "*.test.ts" | xargs grep -l "Parameter" | head -10

# [14]
find /testbed/src -name "StructureDefinition.ts" -type f

# [15]
grep -n "validateValueAtPath" /testbed/src/fhirtypes/StructureDefinition.ts | head -5

# [16]
sed -n '441,600p' /testbed/src/fhirtypes/StructureDefinition.ts

# [17]
cat > /testbed/test_parameters.fsh << 'EOF'
Instance: PatientEx12
InstanceOf: Patient
Usage: #inline

Instance: ParametersEx12
InstanceOf: Parameters
Usage: #inline
* parameter.name = "patient"
* parameter.valueReference = Reference(PatientEx12)
EOF

# [18]
cat /testbed/package.json | grep -A 5 "scripts"

# [19]
find /testbed/test -name "*Instance*.test.ts" | head -5

# [20]
head -100 /testbed/test/export/InstanceExporter.test.ts

# [21]
grep -n "export function setPropertyOnInstance" /testbed/src/fhirtypes/common.ts

# [22]
sed -n '120,250p' /testbed/src/fhirtypes/common.ts

# [23]
grep -n "\.forEach" /testbed/src/fhirtypes/common.ts | grep -v "?\.forEach"

# [24]
sed -n '385,420p' /testbed/src/fhirtypes/common.ts

# [25]
cat /testbed/src/fshtypes/Instance.ts

# [26]
grep -n "new Instance" /testbed/src/import/FSHImporter.ts | head -10

# [27]
sed -n '310,350p' /testbed/src/import/FSHImporter.ts

# [28]
grep -rn "Bundle" /testbed/src/export --include="*.ts" | grep -i instance | head -20

# [29]
grep -n "Bundle" /testbed/src/ig/IGExporter.ts | head -20

# [30]
grep -n "FshReference" /testbed/src/fhirtypes/common.ts | head -20

# [31]
sed -n '230,280p' /testbed/src/fhirtypes/common.ts

# [32]
cat > /testbed/reproduce_issue.js << 'EOF'
const { FHIRDefinitions } = require('./dist/fhirdefs');
const { FSHTank, FSHDocument } = require('./dist/import');
const { Package, InstanceExporter, StructureDefinitionExporter } = require('./dist/export');
const { Instance, FshReference } = require('./dist/fshtypes');
const { FixedValueRule } = require('./dist/fshtypes/rules');
const path = require('path');

async function run() {
  const defs = new FHIRDefinitions();
  await defs.loadFromPath(path.join(__dirname, 'test', 'testhelpers', 'testdefs', 'package'));
  
  const doc = new FSHDocument('test.fsh');
  const config = {
    canonical: 'http://example.org',
    fhirVersion: ['4.0.1']
  };
  const tank = new FSHTank([doc], config);
  const pkg = new Package(config);
  
  // Create PatientEx12 inline instance
  const patientInstance = new Instance('PatientEx12');
  patientInstance.instanceOf = 'Patient';
  patientInstance.usage = 'Inline';
  doc.instances.set(patientInstance.name, patientInstance);
  
  // Create ParametersEx12 inline instance with parameter.valueReference
  const paramsInstance = new Instance('ParametersEx12');
  paramsInstance.instanceOf = 'Parameters';
  paramsInstance.usage = 'Inline';
  
  // Add rule for parameter.name
  const nameRule = new FixedValueRule('parameter.name');
  nameRule.fixedValue = 'patient';
  paramsInstance.rules.push(nameRule);
  
  // Add rule for parameter.valueReference
  const refRule = new FixedValueRule('parameter.valueReference');
  refRule.fixedValue = new FshReference('PatientEx12');
  refRule.isInstance = true;
  paramsInstance.rules.push(refRule);
  
  doc.instances.set(paramsInstance.name, paramsInstance);
  
  class TestFisher {
    constructor(tank, defs, pkg) {
      this.tank = tank;
      this.defs = defs;
      this.pkg = pkg;
    }
    
    fishForFHIR(item, ...types) {
      return this.defs.fish(item, ...types);
    }
    
    fishForMetadata(item, ...types) {
      const result = this.defs.fish(item, ...types);
      if (result) {
        return {
          sdType: result.resourceType || result.type,
          url: result.url
        };
      }
      return null;
    }
  }
  
  const fisher = new TestFisher(tank, defs, pkg);
  const sdExporter = new StructureDefinitionExporter(tank, pkg, fisher);
  const exporter = new InstanceExporter(tank, pkg, fisher);
  
  try {
    sdExporter.export();
    exporter.export();
    console.log('Export successful!');
    console.log('Instances:', pkg.instances.map(i => i._instanceMeta.name));
  } catch (e) {
    console.error('Error:', e.message);
    console.error('Stack:', e.stack);
  }
}

run().catch(console.error);
EOF

# [33]
cd /testbed && npm run build 2>&1 | tail -20

# [34]
cd /testbed && node reproduce_issue.js

# [35]
cat > /testbed/reproduce_issue.js << 'EOF'
const { FHIRDefinitions, loadFromPath } = require('./dist/fhirdefs');
const { FSHTank, FSHDocument } = require('./dist/import');
const { Package, InstanceExporter, StructureDefinitionExporter } = require('./dist/export');
const { Instance, FshReference } = require('./dist/fshtypes');
const { FixedValueRule } = require('./dist/fshtypes/rules');
const path = require('path');

async function run() {
  const defs = new FHIRDefinitions();
  loadFromPath(path.join(__dirname, 'test', 'testhelpers', 'testdefs', 'package'), 'testPackage', defs);
  
  const doc = new FSHDocument('test.fsh');
  const config = {
    canonical: 'http://example.org',
    fhirVersion: ['4.0.1']
  };
  const tank = new FSHTank([doc], config);
  const pkg = new Package(config);
  
  // Create PatientEx12 inline instance
  const patientInstance = new Instance('PatientEx12');
  patientInstance.instanceOf = 'Patient';
  patientInstance.usage = 'Inline';
  doc.instances.set(patientInstance.name, patientInstance);
  
  // Create ParametersEx12 inline instance with parameter.valueReference
  const paramsInstance = new Instance('ParametersEx12');
  paramsInstance.instanceOf = 'Parameters';
  paramsInstance.usage = 'Inline';
  
  // Add rule for parameter.name
  const nameRule = new FixedValueRule('parameter.name');
  nameRule.fixedValue = 'patient';
  paramsInstance.rules.push(nameRule);
  
  // Add rule for parameter.valueReference
  const refRule = new FixedValueRule('parameter.valueReference');
  refRule.fixedValue = new FshReference('PatientEx12');
  refRule.isInstance = true;
  paramsInstance.rules.push(refRule);
  
  doc.instances.set(paramsInstance.name, paramsInstance);
  
  class TestFisher {
    constructor(tank, defs, pkg) {
      this.tank = tank;
      this.defs = defs;
      this.pkg = pkg;
    }
    
    fishForFHIR(item, ...types) {
      return this.defs.fish(item, ...types);
    }
    
    fishForMetadata(item, ...types) {
      const result = this.defs.fish(item, ...types);
      if (result) {
        return {
          sdType: result.resourceType || result.type,
          url: result.url
        };
      }
      return null;
    }
  }
  
  const fisher = new TestFisher(tank, defs, pkg);
  const sdExporter = new StructureDefinitionExporter(tank, pkg, fisher);
  const exporter = new InstanceExporter(tank, pkg, fisher);
  
  try {
    sdExporter.export();
    exporter.export();
    console.log('Export successful!');
    console.log('Instances:', pkg.instances.map(i => i._instanceMeta.name));
  } catch (e) {
    console.error('Error:', e.message);
    console.error('Stack:', e.stack);
  }
}

run().catch(console.error);
EOF

# [36]
cd /testbed && node reproduce_issue.js 2>&1

# [37]
grep -rn "valueReference" /testbed/test --include="*.test.ts" | head -10

# [38]
grep -rn "\.forEach" /testbed/src/export/InstanceExporter.ts

# [39]
sed -n '130,170p' /testbed/src/export/InstanceExporter.ts

# [40]
grep -B5 -A5 "fshDefinition.rules" /testbed/src/fhirtypes/common.ts | head -40

# [41]
sed -n '340,365p' /testbed/src/fhirtypes/common.ts

# [42]
sed -n '365,385p' /testbed/src/fhirtypes/common.ts

# [43]
sed -n '220,265p' /testbed/src/fhirtypes/common.ts

# [44]
ls /testbed/test/testhelpers/testdefs/package/ | grep -i parameter

# [45]
find /testbed/test/testhelpers/testdefs/package -name "*Parameters*" -o -name "*parameters*" | head -5

# [46]
sed -n '40,75p' /testbed/src/export/InstanceExporter.ts

# [47]
sed -n '275,300p' /testbed/src/export/InstanceExporter.ts

# [48]
sed -n '253,270p' /testbed/src/export/InstanceExporter.ts

# [49]
sed -n '235,252p' /testbed/src/export/InstanceExporter.ts

# [50]
sed -n '215,235p' /testbed/src/export/InstanceExporter.ts

# [51]
grep -n "fishForFHIR" /testbed/src/export/InstanceExporter.ts

# [52]
sed -n '197,213p' /testbed/src/export/InstanceExporter.ts

# [53]
grep -rn "parameter" /testbed/src --include="*.ts" | grep -i "foreach\|\.rules" | head -20

# [54]
grep -rn "Bundle" /testbed/src/export --include="*.ts" -A3 -B3 | head -50

# [55]
sed -n '30,50p' /testbed/src/export/InstanceExporter.ts

# [56]
sed -n '385,430p' /testbed/src/fhirtypes/common.ts

# [57]
grep -rn "\.rules\s*=" /testbed/src --include="*.ts" | grep -v "//.*\.rules" | head -20

# [58]
grep -rn "fromJSON\|Object.assign" /testbed/src/fshtypes/Instance.ts

# [59]
grep -rn "cloneDeep.*Instance\|Object.assign.*Instance" /testbed/src --include="*.ts" | head -10

# [60]
sed -n '405,415p' /testbed/src/fhirtypes/common.ts

# [61]
grep -n "fish.*Type.RuleSet" /testbed/src/import/FSHTank.ts -A10 | head -30

# [62]
grep -n "fish(" /testbed/src/import/FSHTank.ts | head -10

# [63]
sed -n '105,160p' /testbed/src/import/FSHTank.ts

# [64]
grep -rn "\.forEach" /testbed/src/fhirtypes/common.ts | grep -v "?\.forEach" | grep -v "Map\|Set"

# [65]
grep -rn "Cannot read property" /testbed/test --include="*.test.ts" | head -5

# [66]
cd /testbed && git log --oneline --all | head -20

# [67]
cd /testbed && git log --all --grep="Parameters" --oneline | head -10

# [68]
sed -n '385,445p' /testbed/src/fhirtypes/common.ts

# [69]
sed -n '335,380p' /testbed/src/fhirtypes/common.ts

# [70]
sed -n '275,285p' /testbed/src/export/InstanceExporter.ts

# [71]
sed -n '28,35p' /testbed/src/export/InstanceExporter.ts

# [72]
cat > /tmp/fix.patch << 'EOF'
--- a/src/fhirtypes/common.ts
+++ b/src/fhirtypes/common.ts
@@ -388,7 +388,7 @@ export function applyInsertRules(
   tank: FSHTank,
   seenRuleSets: string[] = []
 ): void {
   const expandedRules: Rule[] = [];
-  fshDefinition.rules.forEach(rule => {
+  (fshDefinition.rules ?? []).forEach(rule => {
     if (!(rule instanceof InsertRule)) {
       expandedRules.push(rule);
       return;
EOF

# [73]
sed -n '354p' /testbed/src/fhirtypes/common.ts

# [74]
sed -n '397,410p' /testbed/src/fhirtypes/common.ts

# [75]
sed -n '354,360p' /testbed/src/fhirtypes/common.ts

# [76]
grep -rn "parameter" /testbed/src/fhirtypes/StructureDefinition.ts | head -20

# [77]
sed -i '356s/ruleSet\.rules\.forEach/(ruleSet.rules ?? []).forEach/' /testbed/src/fhirtypes/common.ts

# [78]
sed -i '391s/fshDefinition\.rules\.forEach/(fshDefinition.rules ?? []).forEach/' /testbed/src/fhirtypes/common.ts

# [79]
sed -i '408s/ruleSet\.rules\.forEach/(ruleSet.rules ?? []).forEach/' /testbed/src/fhirtypes/common.ts

# [80]
sed -n '354,360p' /testbed/src/fhirtypes/common.ts

# [81]
grep -n "ruleSet.rules.forEach" /testbed/src/fhirtypes/common.ts

# [82]
grep -n "fshDefinition.rules.forEach" /testbed/src/fhirtypes/common.ts

# [83]
sed -n '391p' /testbed/src/fhirtypes/common.ts

# [84]
sed -n '408p' /testbed/src/fhirtypes/common.ts

# [85]
sed -i '357s/ruleSet\.rules\.forEach/(ruleSet.rules ?? []).forEach/' /testbed/src/fhirtypes/common.ts

# [86]
sed -n '357p' /testbed/src/fhirtypes/common.ts

# [87]
sed -n '377p' /testbed/src/fhirtypes/common.ts

# [88]
sed -i '377s/\.\.\.fshDefinition\.rules/...fshDefinition.rules ?? []/' /testbed/src/fhirtypes/common.ts

# [89]
sed -n '377p' /testbed/src/fhirtypes/common.ts

# [90]
sed -i '377s/\.\.\.fshDefinition\.rules ?? \[\]/...(fshDefinition.rules ?? [])/' /testbed/src/fhirtypes/common.ts

# [91]
sed -n '377p' /testbed/src/fhirtypes/common.ts

# [92]
cd /testbed && npm run build 2>&1 | grep -E "error|Error" | head -20

# [93]
cd /testbed && npm test 2>&1 | tail -50

# [94]
cat > /testbed/test_parameters_fix.js << 'EOF'
const { FHIRDefinitions, loadFromPath } = require('./dist/fhirdefs');
const { FSHTank, FSHDocument } = require('./dist/import');
const { Package, InstanceExporter, StructureDefinitionExporter } = require('./dist/export');
const { Instance, FshReference } = require('./dist/fshtypes');
const { FixedValueRule } = require('./dist/fshtypes/rules');
const path = require('path');

function run() {
  const defs = new FHIRDefinitions();
  loadFromPath(path.join(__dirname, 'test', 'testhelpers', 'testdefs', 'package'), 'testPackage', defs);
  
  const doc = new FSHDocument('test.fsh');
  const config = {
    canonical: 'http://example.org',
    fhirVersion: ['4.0.1']
  };
  const tank = new FSHTank([doc], config);
  const pkg = new Package(config);
  
  // Create PatientEx12 inline instance
  const patientInstance = new Instance('PatientEx12');
  patientInstance.instanceOf = 'Patient';
  patientInstance.usage = 'Inline';
  doc.instances.set(patientInstance.name, patientInstance);
  
  // Create ParametersEx12 inline instance with parameter.valueReference
  const paramsInstance = new Instance('ParametersEx12');
  paramsInstance.instanceOf = 'Parameters';
  paramsInstance.usage = 'Inline';
  
  // Add rule for parameter.name
  const nameRule = new FixedValueRule('parameter.name');
  nameRule.fixedValue = 'patient';
  paramsInstance.rules.push(nameRule);
  
  // Add rule for parameter.valueReference
  const refRule = new FixedValueRule('parameter.valueReference');
  refRule.fixedValue = new FshReference('PatientEx12');
  refRule.isInstance = true;
  paramsInstance.rules.push(refRule);
  
  doc.instances.set(paramsInstance.name, paramsInstance);
  
  class TestFisher {
    constructor(tank, defs, pkg) {
      this.tank = tank;
      this.defs = defs;
      this.pkg = pkg;
    }
    
    fishForFHIR(item, ...types) {
      return this.defs.fish(item, ...types);
    }
    
    fishForMetadata(item, ...types) {
      const result = this.defs.fish(item, ...types);
      if (result) {
        return {
          sdType: result.resourceType || result.type,
          url: result.url
        };
      }
      return null;
    }
  }
  
  const fisher = new TestFisher(tank, defs, pkg);
  const sdExporter = new StructureDefinitionExporter(tank, pkg, fisher);
  const exporter = new InstanceExporter(tank, pkg, fisher);
  
  try {
    sdExporter.export();
    exporter.export();
    console.log('✓ Export successful!');
    console.log('Instances exported:', pkg.instances.length);
    if (pkg.instances.length > 0) {
      console.log('Instance names:', pkg.instances.map(i => i._instanceMeta.name));
    }
    return true;
  } catch (e) {
    console.error('✗ Error:', e.message);
    console.error('Stack:', e.stack);
    return false;
  }
}

const success = run();
process.exit(success ? 0 : 1);
EOF

# [95]
cd /testbed && node test_parameters_fix.js 2>&1 | grep -v "Warning:"

# [96]
grep -rn "Parameters" /testbed/test/export/InstanceExporter.test.ts | head -10

# [97]
cd /testbed && git diff src/fhirtypes/common.ts

# [98]
grep -rn "new Instance\|new RuleSet" /testbed/src --include="*.ts" | grep -v "test" | head -20

# [99]
grep -rn "new Instance" /testbed/src --include="*.ts" | head -20

# [100]
grep -rn "new RuleSet" /testbed/src --include="*.ts" | head -20

# [101]
cd /testbed && npm test -- --testPathPattern="InstanceExporter" 2>&1 | tail -30

# [102]
cd /testbed && npm test -- --testPathPattern="common" 2>&1 | tail -20

# [103]
grep -rn "applyInsertRules\|applyMixinRules" /testbed/test --include="*.test.ts" | head -10

# [104]
cd /testbed && npm test -- --testPathPattern="applyInsertRules" 2>&1 | tail -30

# [105]
cat > /testbed/verify_fix.js << 'EOF'
// This script verifies that the fix prevents the "Cannot read property 'forEach' of undefined" error
// when processing Parameters instances with valueReference to inline instances

const { applyInsertRules, applyMixinRules } = require('./dist/fhirtypes/common');
const { Instance, Profile, RuleSet } = require('./dist/fshtypes');
const { FSHTank, FSHDocument } = require('./dist/import');

console.log('Testing defensive checks for undefined rules...\n');

// Test 1: Instance with undefined rules
console.log('Test 1: Instance with undefined rules');
try {
  const doc = new FSHDocument('test.fsh');
  const config = { canonical: 'http://example.org', fhirVersion: ['4.0.1'] };
  const tank = new FSHTank([doc], config);
  
  const instance = new Instance('TestInstance');
  instance.instanceOf = 'Patient';
  // Simulate undefined rules (shouldn't happen in practice, but we're testing defensive code)
  instance.rules = undefined;
  
  applyInsertRules(instance, tank);
  console.log('✓ applyInsertRules handled undefined rules without crashing\n');
} catch (e) {
  console.error('✗ Failed:', e.message, '\n');
  process.exit(1);
}

// Test 2: Profile with undefined rules
console.log('Test 2: Profile with undefined rules');
try {
  const doc = new FSHDocument('test.fsh');
  const config = { canonical: 'http://example.org', fhirVersion: ['4.0.1'] };
  const tank = new FSHTank([doc], config);
  
  const profile = new Profile('TestProfile');
  profile.parent = 'Patient';
  profile.rules = undefined;
  
  applyMixinRules(profile, tank);
  console.log('✓ applyMixinRules handled undefined rules without crashing\n');
} catch (e) {
  console.error('✗ Failed:', e.message, '\n');
  process.exit(1);
}

// Test 3: RuleSet with undefined rules
console.log('Test 3: RuleSet with undefined rules in applyInsertRules');
try {
  const doc = new FSHDocument('test.fsh');
  const config = { canonical: 'http://example.org', fhirVersion: ['4.0.1'] };
  const tank = new FSHTank([doc], config);
  
  const ruleSet = new RuleSet('TestRuleSet');
  ruleSet.rules = undefined;
  doc.ruleSets.set(ruleSet.name, ruleSet);
  
  const profile = new Profile('TestProfile');
  profile.parent = 'Patient';
  // Add an insert rule that references the RuleSet
  const { InsertRule } = require('./dist/fshtypes/rules');
  const insertRule = new InsertRule('');
  insertRule.ruleSet = 'TestRuleSet';
  profile.rules.push(insertRule);
  
  applyInsertRules(profile, tank);
  console.log('✓ applyInsertRules handled RuleSet with undefined rules without crashing\n');
} catch (e) {
  console.error('✗ Failed:', e.message, '\n');
  process.exit(1);
}

console.log('All tests passed! ✓');
process.exit(0);
EOF

# [106]
cd /testbed && node verify_fix.js 2>&1 | grep -v "Warning:"

# [107]
cd /testbed && git diff src/

# [108]
cd /testbed && git diff src/fhirtypes/common.ts > patch.txt

# [109]
cat patch.txt
