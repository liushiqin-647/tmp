#!/usr/bin/env bash
# fhir__sushi-513，共 109 条命令，按轨迹原顺序执行
# 控制台只打印每条命令的退出码和耗时；命令输出写到 /tmp/traj-run_sushi_513/step-<序号>.log
LOG_DIR="${LOG_DIR:-/tmp/traj-run_sushi_513}"
mkdir -p "$LOG_DIR"

run() {
  local n=$1 cmd start end rc
  cmd=$(cat)
  start=$(date +%s%3N)
  ( eval "$cmd" ) >"$LOG_DIR/step-$n.log" 2>&1
  rc=$?
  end=$(date +%s%3N)
  printf '[%s] rc=%s %sms\n' "$n" "$rc" "$((end - start))"
}

run 1 <<'__STEP_CMD__'
ln -sfn /sushi /testbed && ls /testbed | head -3; go clean -cache 2>/dev/null; rm -rf /testbed/target /testbed/dist /testbed/build /testbed/out /testbed/.gradle /testbed/node_modules/.cache 2>/dev/null; find /testbed -name '__pycache__' -type d -prune -exec rm -rf {} + 2>/dev/null; find /testbed -name '*.tsbuildinfo' -delete 2>/dev/null; find /testbed -name '*.o' -delete 2>/dev/null; true; rm -rf /tmp/jest_* /testbed/node_modules/.vite /testbed/.parcel-cache /testbed/.eslintcache 2>/dev/null; true
__STEP_CMD__

run 2 <<'__STEP_CMD__'
find /testbed -type f -name "*.js" -o -name "*.ts" | head -20
__STEP_CMD__

run 3 <<'__STEP_CMD__'
ls -la /testbed
__STEP_CMD__

run 4 <<'__STEP_CMD__'
grep -r "forEach" /testbed/src --include="*.ts" --include="*.js" | grep -i parameter | head -20
__STEP_CMD__

run 5 <<'__STEP_CMD__'
find /testbed/src -type f -name "*.ts" | xargs grep -l "Parameters" | head -20
__STEP_CMD__

run 6 <<'__STEP_CMD__'
find /testbed/src -type f -name "*.ts" | xargs grep -l "Instance" | head -20
__STEP_CMD__

run 7 <<'__STEP_CMD__'
wc -l /testbed/src/export/InstanceExporter.ts
__STEP_CMD__

run 8 <<'__STEP_CMD__'
cat /testbed/src/export/InstanceExporter.ts
__STEP_CMD__

run 9 <<'__STEP_CMD__'
grep -n "forEach" /testbed/src/export/InstanceExporter.ts
__STEP_CMD__

run 10 <<'__STEP_CMD__'
grep -n "forEach" /testbed/src/fhirtypes/common.ts | head -30
__STEP_CMD__

run 11 <<'__STEP_CMD__'
sed -n '140,160p' /testbed/src/fhirtypes/common.ts
__STEP_CMD__

run 12 <<'__STEP_CMD__'
find /testbed/test -type f -name "*.test.ts" | xargs grep -l "Parameters" | head -10
__STEP_CMD__

run 13 <<'__STEP_CMD__'
find /testbed/test -type f -name "*.test.ts" | xargs grep -l "Parameter" | head -10
__STEP_CMD__

run 14 <<'__STEP_CMD__'
find /testbed/src -name "StructureDefinition.ts" -type f
__STEP_CMD__

run 15 <<'__STEP_CMD__'
grep -n "validateValueAtPath" /testbed/src/fhirtypes/StructureDefinition.ts | head -5
__STEP_CMD__

run 16 <<'__STEP_CMD__'
sed -n '441,600p' /testbed/src/fhirtypes/StructureDefinition.ts
__STEP_CMD__

run 17 <<'__STEP_CMD__'
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
__STEP_CMD__

run 18 <<'__STEP_CMD__'
cat /testbed/package.json | grep -A 5 "scripts"
__STEP_CMD__

run 19 <<'__STEP_CMD__'
find /testbed/test -name "*Instance*.test.ts" | head -5
__STEP_CMD__

run 20 <<'__STEP_CMD__'
head -100 /testbed/test/export/InstanceExporter.test.ts
__STEP_CMD__

run 21 <<'__STEP_CMD__'
grep -n "export function setPropertyOnInstance" /testbed/src/fhirtypes/common.ts
__STEP_CMD__

run 22 <<'__STEP_CMD__'
sed -n '120,250p' /testbed/src/fhirtypes/common.ts
__STEP_CMD__

run 23 <<'__STEP_CMD__'
grep -n "\.forEach" /testbed/src/fhirtypes/common.ts | grep -v "?\.forEach"
__STEP_CMD__

run 24 <<'__STEP_CMD__'
sed -n '385,420p' /testbed/src/fhirtypes/common.ts
__STEP_CMD__

run 25 <<'__STEP_CMD__'
cat /testbed/src/fshtypes/Instance.ts
__STEP_CMD__

run 26 <<'__STEP_CMD__'
grep -n "new Instance" /testbed/src/import/FSHImporter.ts | head -10
__STEP_CMD__

run 27 <<'__STEP_CMD__'
sed -n '310,350p' /testbed/src/import/FSHImporter.ts
__STEP_CMD__

run 28 <<'__STEP_CMD__'
grep -rn "Bundle" /testbed/src/export --include="*.ts" | grep -i instance | head -20
__STEP_CMD__

run 29 <<'__STEP_CMD__'
grep -n "Bundle" /testbed/src/ig/IGExporter.ts | head -20
__STEP_CMD__

run 30 <<'__STEP_CMD__'
grep -n "FshReference" /testbed/src/fhirtypes/common.ts | head -20
__STEP_CMD__

run 31 <<'__STEP_CMD__'
sed -n '230,280p' /testbed/src/fhirtypes/common.ts
__STEP_CMD__

run 32 <<'__STEP_CMD__'
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
__STEP_CMD__

run 33 <<'__STEP_CMD__'
cd /testbed && npm run build 2>&1 | tail -20
__STEP_CMD__

run 34 <<'__STEP_CMD__'
cd /testbed && node reproduce_issue.js
__STEP_CMD__

run 35 <<'__STEP_CMD__'
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
__STEP_CMD__

run 36 <<'__STEP_CMD__'
cd /testbed && node reproduce_issue.js 2>&1
__STEP_CMD__

run 37 <<'__STEP_CMD__'
grep -rn "valueReference" /testbed/test --include="*.test.ts" | head -10
__STEP_CMD__

run 38 <<'__STEP_CMD__'
grep -rn "\.forEach" /testbed/src/export/InstanceExporter.ts
__STEP_CMD__

run 39 <<'__STEP_CMD__'
sed -n '130,170p' /testbed/src/export/InstanceExporter.ts
__STEP_CMD__

run 40 <<'__STEP_CMD__'
grep -B5 -A5 "fshDefinition.rules" /testbed/src/fhirtypes/common.ts | head -40
__STEP_CMD__

run 41 <<'__STEP_CMD__'
sed -n '340,365p' /testbed/src/fhirtypes/common.ts
__STEP_CMD__

run 42 <<'__STEP_CMD__'
sed -n '365,385p' /testbed/src/fhirtypes/common.ts
__STEP_CMD__

run 43 <<'__STEP_CMD__'
sed -n '220,265p' /testbed/src/fhirtypes/common.ts
__STEP_CMD__

run 44 <<'__STEP_CMD__'
ls /testbed/test/testhelpers/testdefs/package/ | grep -i parameter
__STEP_CMD__

run 45 <<'__STEP_CMD__'
find /testbed/test/testhelpers/testdefs/package -name "*Parameters*" -o -name "*parameters*" | head -5
__STEP_CMD__

run 46 <<'__STEP_CMD__'
sed -n '40,75p' /testbed/src/export/InstanceExporter.ts
__STEP_CMD__

run 47 <<'__STEP_CMD__'
sed -n '275,300p' /testbed/src/export/InstanceExporter.ts
__STEP_CMD__

run 48 <<'__STEP_CMD__'
sed -n '253,270p' /testbed/src/export/InstanceExporter.ts
__STEP_CMD__

run 49 <<'__STEP_CMD__'
sed -n '235,252p' /testbed/src/export/InstanceExporter.ts
__STEP_CMD__

run 50 <<'__STEP_CMD__'
sed -n '215,235p' /testbed/src/export/InstanceExporter.ts
__STEP_CMD__

run 51 <<'__STEP_CMD__'
grep -n "fishForFHIR" /testbed/src/export/InstanceExporter.ts
__STEP_CMD__

run 52 <<'__STEP_CMD__'
sed -n '197,213p' /testbed/src/export/InstanceExporter.ts
__STEP_CMD__

run 53 <<'__STEP_CMD__'
grep -rn "parameter" /testbed/src --include="*.ts" | grep -i "foreach\|\.rules" | head -20
__STEP_CMD__

run 54 <<'__STEP_CMD__'
grep -rn "Bundle" /testbed/src/export --include="*.ts" -A3 -B3 | head -50
__STEP_CMD__

run 55 <<'__STEP_CMD__'
sed -n '30,50p' /testbed/src/export/InstanceExporter.ts
__STEP_CMD__

run 56 <<'__STEP_CMD__'
sed -n '385,430p' /testbed/src/fhirtypes/common.ts
__STEP_CMD__

run 57 <<'__STEP_CMD__'
grep -rn "\.rules\s*=" /testbed/src --include="*.ts" | grep -v "//.*\.rules" | head -20
__STEP_CMD__

run 58 <<'__STEP_CMD__'
grep -rn "fromJSON\|Object.assign" /testbed/src/fshtypes/Instance.ts
__STEP_CMD__

run 59 <<'__STEP_CMD__'
grep -rn "cloneDeep.*Instance\|Object.assign.*Instance" /testbed/src --include="*.ts" | head -10
__STEP_CMD__

run 60 <<'__STEP_CMD__'
sed -n '405,415p' /testbed/src/fhirtypes/common.ts
__STEP_CMD__

run 61 <<'__STEP_CMD__'
grep -n "fish.*Type.RuleSet" /testbed/src/import/FSHTank.ts -A10 | head -30
__STEP_CMD__

run 62 <<'__STEP_CMD__'
grep -n "fish(" /testbed/src/import/FSHTank.ts | head -10
__STEP_CMD__

run 63 <<'__STEP_CMD__'
sed -n '105,160p' /testbed/src/import/FSHTank.ts
__STEP_CMD__

run 64 <<'__STEP_CMD__'
grep -rn "\.forEach" /testbed/src/fhirtypes/common.ts | grep -v "?\.forEach" | grep -v "Map\|Set"
__STEP_CMD__

run 65 <<'__STEP_CMD__'
grep -rn "Cannot read property" /testbed/test --include="*.test.ts" | head -5
__STEP_CMD__

run 66 <<'__STEP_CMD__'
cd /testbed && git log --oneline --all | head -20
__STEP_CMD__

run 67 <<'__STEP_CMD__'
cd /testbed && git log --all --grep="Parameters" --oneline | head -10
__STEP_CMD__

run 68 <<'__STEP_CMD__'
sed -n '385,445p' /testbed/src/fhirtypes/common.ts
__STEP_CMD__

run 69 <<'__STEP_CMD__'
sed -n '335,380p' /testbed/src/fhirtypes/common.ts
__STEP_CMD__

run 70 <<'__STEP_CMD__'
sed -n '275,285p' /testbed/src/export/InstanceExporter.ts
__STEP_CMD__

run 71 <<'__STEP_CMD__'
sed -n '28,35p' /testbed/src/export/InstanceExporter.ts
__STEP_CMD__

run 72 <<'__STEP_CMD__'
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
__STEP_CMD__

run 73 <<'__STEP_CMD__'
sed -n '354p' /testbed/src/fhirtypes/common.ts
__STEP_CMD__

run 74 <<'__STEP_CMD__'
sed -n '397,410p' /testbed/src/fhirtypes/common.ts
__STEP_CMD__

run 75 <<'__STEP_CMD__'
sed -n '354,360p' /testbed/src/fhirtypes/common.ts
__STEP_CMD__

run 76 <<'__STEP_CMD__'
grep -rn "parameter" /testbed/src/fhirtypes/StructureDefinition.ts | head -20
__STEP_CMD__

run 77 <<'__STEP_CMD__'
sed -i '356s/ruleSet\.rules\.forEach/(ruleSet.rules ?? []).forEach/' /testbed/src/fhirtypes/common.ts
__STEP_CMD__

run 78 <<'__STEP_CMD__'
sed -i '391s/fshDefinition\.rules\.forEach/(fshDefinition.rules ?? []).forEach/' /testbed/src/fhirtypes/common.ts
__STEP_CMD__

run 79 <<'__STEP_CMD__'
sed -i '408s/ruleSet\.rules\.forEach/(ruleSet.rules ?? []).forEach/' /testbed/src/fhirtypes/common.ts
__STEP_CMD__

run 80 <<'__STEP_CMD__'
sed -n '354,360p' /testbed/src/fhirtypes/common.ts
__STEP_CMD__

run 81 <<'__STEP_CMD__'
grep -n "ruleSet.rules.forEach" /testbed/src/fhirtypes/common.ts
__STEP_CMD__

run 82 <<'__STEP_CMD__'
grep -n "fshDefinition.rules.forEach" /testbed/src/fhirtypes/common.ts
__STEP_CMD__

run 83 <<'__STEP_CMD__'
sed -n '391p' /testbed/src/fhirtypes/common.ts
__STEP_CMD__

run 84 <<'__STEP_CMD__'
sed -n '408p' /testbed/src/fhirtypes/common.ts
__STEP_CMD__

run 85 <<'__STEP_CMD__'
sed -i '357s/ruleSet\.rules\.forEach/(ruleSet.rules ?? []).forEach/' /testbed/src/fhirtypes/common.ts
__STEP_CMD__

run 86 <<'__STEP_CMD__'
sed -n '357p' /testbed/src/fhirtypes/common.ts
__STEP_CMD__

run 87 <<'__STEP_CMD__'
sed -n '377p' /testbed/src/fhirtypes/common.ts
__STEP_CMD__

run 88 <<'__STEP_CMD__'
sed -i '377s/\.\.\.fshDefinition\.rules/...fshDefinition.rules ?? []/' /testbed/src/fhirtypes/common.ts
__STEP_CMD__

run 89 <<'__STEP_CMD__'
sed -n '377p' /testbed/src/fhirtypes/common.ts
__STEP_CMD__

run 90 <<'__STEP_CMD__'
sed -i '377s/\.\.\.fshDefinition\.rules ?? \[\]/...(fshDefinition.rules ?? [])/' /testbed/src/fhirtypes/common.ts
__STEP_CMD__

run 91 <<'__STEP_CMD__'
sed -n '377p' /testbed/src/fhirtypes/common.ts
__STEP_CMD__

run 92 <<'__STEP_CMD__'
cd /testbed && npm run build 2>&1 | grep -E "error|Error" | head -20
__STEP_CMD__

run 93 <<'__STEP_CMD__'
cd /testbed && npm test 2>&1 | tail -50
__STEP_CMD__

run 94 <<'__STEP_CMD__'
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
__STEP_CMD__

run 95 <<'__STEP_CMD__'
cd /testbed && node test_parameters_fix.js 2>&1 | grep -v "Warning:"
__STEP_CMD__

run 96 <<'__STEP_CMD__'
grep -rn "Parameters" /testbed/test/export/InstanceExporter.test.ts | head -10
__STEP_CMD__

run 97 <<'__STEP_CMD__'
cd /testbed && git diff src/fhirtypes/common.ts
__STEP_CMD__

run 98 <<'__STEP_CMD__'
grep -rn "new Instance\|new RuleSet" /testbed/src --include="*.ts" | grep -v "test" | head -20
__STEP_CMD__

run 99 <<'__STEP_CMD__'
grep -rn "new Instance" /testbed/src --include="*.ts" | head -20
__STEP_CMD__

run 100 <<'__STEP_CMD__'
grep -rn "new RuleSet" /testbed/src --include="*.ts" | head -20
__STEP_CMD__

run 101 <<'__STEP_CMD__'
cd /testbed && npm test -- --testPathPattern="InstanceExporter" 2>&1 | tail -30
__STEP_CMD__

run 102 <<'__STEP_CMD__'
cd /testbed && npm test -- --testPathPattern="common" 2>&1 | tail -20
__STEP_CMD__

run 103 <<'__STEP_CMD__'
grep -rn "applyInsertRules\|applyMixinRules" /testbed/test --include="*.test.ts" | head -10
__STEP_CMD__

run 104 <<'__STEP_CMD__'
cd /testbed && npm test -- --testPathPattern="applyInsertRules" 2>&1 | tail -30
__STEP_CMD__

run 105 <<'__STEP_CMD__'
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
__STEP_CMD__

run 106 <<'__STEP_CMD__'
cd /testbed && node verify_fix.js 2>&1 | grep -v "Warning:"
__STEP_CMD__

run 107 <<'__STEP_CMD__'
cd /testbed && git diff src/
__STEP_CMD__

run 108 <<'__STEP_CMD__'
cd /testbed && git diff src/fhirtypes/common.ts > patch.txt
__STEP_CMD__

run 109 <<'__STEP_CMD__'
cat patch.txt
__STEP_CMD__
