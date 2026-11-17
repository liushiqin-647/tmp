#!/usr/bin/env bash
# fhir__sushi-439，共 94 条命令，按轨迹原顺序执行

# [1]
ln -sfn /sushi /testbed && ls /testbed | head -3; go clean -cache 2>/dev/null; rm -rf /testbed/target /testbed/dist /testbed/build /testbed/out /testbed/.gradle /testbed/node_modules/.cache 2>/dev/null; find /testbed -name '__pycache__' -type d -prune -exec rm -rf {} + 2>/dev/null; find /testbed -name '*.tsbuildinfo' -delete 2>/dev/null; find /testbed -name '*.o' -delete 2>/dev/null; true; rm -rf /tmp/jest_* /testbed/node_modules/.vite /testbed/.parcel-cache /testbed/.eslintcache 2>/dev/null; true

# [2]
find /testbed -type f -name "*.ts" -o -name "*.js" | grep -E "(error|slice)" | head -20

# [3]
ls -la /testbed/src/errors/ | grep -i slice

# [4]
find /testbed -type f -name "*DuplicateSlice*" 2>/dev/null

# [5]
ls -la /testbed/src/errors/

# [6]
cat /testbed/src/errors/SlicingNotDefinedError.ts

# [7]
cat /testbed/src/errors/InvalidSumOfSliceMinsError.ts

# [8]
cat /testbed/src/errors/Annotated.ts

# [9]
cat /testbed/src/errors/index.ts

# [10]
find /testbed -type f -name "*.ts" | xargs grep -l "ContainsRule" | grep -v test | head -10

# [11]
find /testbed -type f -name "*.ts" | xargs grep -l "ContainsRule" | head -10

# [12]
cat /testbed/src/fshtypes/rules/ContainsRule.ts

# [13]
grep -n "ContainsRule" /testbed/src/export/StructureDefinitionExporter.ts | head -20

# [14]
grep -A 50 "else if (rule instanceof ContainsRule)" /testbed/src/export/StructureDefinitionExporter.ts | head -80

# [15]
find /testbed/src -type f -name "*.ts" | xargs grep -l "addSlice" | grep -v test

# [16]
find /testbed/src -type f -name "*.ts" | xargs grep -l "addSlice"

# [17]
grep -n "addSlice" /testbed/src/fhirtypes/ElementDefinition.ts

# [18]
sed -n '1691,1750p' /testbed/src/fhirtypes/ElementDefinition.ts

# [19]
grep -n "findSlice\|getSlice" /testbed/src/fhirtypes/ElementDefinition.ts | head -20

# [20]
sed -n '419,450p' /testbed/src/fhirtypes/ElementDefinition.ts

# [21]
grep -n "sliceName" /testbed/src/fhirtypes/ElementDefinition.ts | head -20

# [22]
grep -n "findElement\|addElement" /testbed/src/fhirtypes/StructureDefinition.ts | head -20

# [23]
sed -n '166,200p' /testbed/src/fhirtypes/StructureDefinition.ts

# [24]
find /testbed -type f -name "*.test.ts" | xargs grep -l "DuplicateSlice\|duplicate.*slice" | head -5

# [25]
find /testbed -type f -name "*.test.ts" | xargs grep -l "contains.*slice\|slice.*contains" | head -5

# [26]
grep -n "DuplicateSlice" /testbed/test/export/StructureDefinitionExporter.test.ts

# [27]
find /testbed/test -type f -name "*.test.ts" | xargs grep -l "already exists" | head -5

# [28]
grep -n "already exists" /testbed/test/fhirtypes/ElementDefinition.slicing.test.ts | head -10

# [29]
grep -B5 -A10 "Slice named.*already exists" /testbed/test/fhirtypes/*.test.ts

# [30]
find /testbed/test -type f -name "*.test.ts" -exec grep -l "DoubleSlice\|onlySlice" {} \;

# [31]
cd /testbed && git log --oneline --all -20

# [32]
cd /testbed && git status

# [33]
cd /testbed && git diff HEAD --name-only | grep test

# [34]
cd /testbed && git log --all --source --full-history -- "*DuplicateSlice*" 2>/dev/null | head -20

# [35]
sed -n '1691,1720p' /testbed/src/fhirtypes/ElementDefinition.ts

# [36]
sed -n '419,425p' /testbed/src/fhirtypes/ElementDefinition.ts

# [37]
cat > /testbed/src/errors/DuplicateSliceError.ts << 'EOF'
import { Annotated } from './Annotated';

export class DuplicateSliceError extends Error implements Annotated {
  specReferences = ['http://hl7.org/fhir/R4/profiling.html#slicing'];
  constructor(public structDef: string, public element: string, public slice: string) {
    super(`Slice named ${slice} already exists on element ${element} of ${structDef}`);
  }
}
EOF

# [38]
cat /testbed/src/errors/index.ts | grep -n "SliceTypeRemovalError"

# [39]
sed -i "35a export * from './DuplicateSliceError';" /testbed/src/errors/index.ts

# [40]
sed -n '33,38p' /testbed/src/errors/index.ts

# [41]
head -30 /testbed/src/fhirtypes/ElementDefinition.ts | grep import

# [42]
sed -n '1,50p' /testbed/src/fhirtypes/ElementDefinition.ts | grep -A20 "^import"

# [43]
sed -n '9,40p' /testbed/src/fhirtypes/ElementDefinition.ts

# [44]
sed -i '30a\  DuplicateSliceError,' /testbed/src/fhirtypes/ElementDefinition.ts

# [45]
sed -n '9,35p' /testbed/src/fhirtypes/ElementDefinition.ts

# [46]
sed -n '1691,1715p' /testbed/src/fhirtypes/ElementDefinition.ts

# [47]
cat > /tmp/addslice_patch.txt << 'EOF'
  addSlice(name: string, type?: ElementDefinitionType): ElementDefinition {
    if (!this.slicing) {
      throw new SlicingNotDefinedError(this.id, name);
    }
    
    // Check if a slice with this name already exists
    const existingSlices = this.getSlices();
    const existingSlice = existingSlices.find(s => s.sliceName === name);
    if (existingSlice) {
      throw new DuplicateSliceError(this.structDef.id, this.id, name);
    }
    
    const slice = this.clone(true);
    delete slice.slicing;
    slice.id = `${this.id}:${name}`;

    // Capture the original so that the differential only contains changes from this point on.
    slice.captureOriginal();

    slice.sliceName = name;
    // When we slice, we do not inherit min cardinality, but rather make it 0
    // Allows multiple slices to be defined without violating cardinality of sliced element
    // Cardinality can be later narrowed by card constraints, which check validity of narrowing
    // According to https://chat.fhir.org/#narrow/stream/179239-tooling/topic/Slicing.201.2E.2E.3F.20element
    slice.min = 0;
    if (type) {
      slice.type = [type];
    }
    this.structDef.addElement(slice);
    return slice;
  }
EOF

# [48]
grep -n "addSlice(name: string" /testbed/src/fhirtypes/ElementDefinition.ts

# [49]
grep -n "clone(clearOriginal = true)" /testbed/src/fhirtypes/ElementDefinition.ts | head -1

# [50]
sed -i '1692,1715d' /testbed/src/fhirtypes/ElementDefinition.ts

# [51]
sed -i '1691r /tmp/addslice_patch.txt' /testbed/src/fhirtypes/ElementDefinition.ts

# [52]
sed -n '1690,1725p' /testbed/src/fhirtypes/ElementDefinition.ts

# [53]
cat > /tmp/test_duplicate_slice.ts << 'EOF'
import { StructureDefinition } from '../src/fhirtypes/StructureDefinition';
import { ElementDefinition } from '../src/fhirtypes/ElementDefinition';
import { DuplicateSliceError } from '../src/errors/DuplicateSliceError';

// Create a simple test
const structDef = new StructureDefinition('Observation');
structDef.id = 'TestObservation';

// Add an element with slicing
const component = new ElementDefinition('Observation.component');
component.slicing = {
  discriminator: [{ type: 'value', path: 'code' }],
  ordered: false,
  rules: 'open'
};
structDef.addElement(component);

// Add first slice
try {
  const slice1 = component.addSlice('foo');
  console.log('✓ First slice "foo" added successfully');
} catch (e) {
  console.error('✗ Failed to add first slice:', e.message);
}

// Try to add duplicate slice
try {
  const slice2 = component.addSlice('foo');
  console.error('✗ Should have thrown DuplicateSliceError but did not');
} catch (e) {
  if (e instanceof DuplicateSliceError) {
    console.log('✓ Correctly threw DuplicateSliceError:', e.message);
  } else {
    console.error('✗ Threw wrong error type:', e.message);
  }
}

console.log('\nTest completed!');
EOF

# [54]
cd /testbed && ls -la | grep -E "package\.json|tsconfig"

# [55]
cd /testbed && cat package.json | grep -A5 '"scripts"'

# [56]
ls -la /testbed/dist/fhirtypes/ | head -10

# [57]
cd /testbed && npm run build 2>&1 | tail -30

# [58]
ls -la /testbed/dist/errors/ | grep -i duplicate

# [59]
cat /testbed/dist/errors/DuplicateSliceError.js

# [60]
cd /testbed && npm test -- --testPathPattern="ElementDefinition.slicing" --no-coverage 2>&1 | tail -50

# [61]
cat > /tmp/test_duplicate.js << 'EOF'
const { StructureDefinition } = require('/testbed/dist/fhirtypes/StructureDefinition');
const { ElementDefinition } = require('/testbed/dist/fhirtypes/ElementDefinition');
const { DuplicateSliceError } = require('/testbed/dist/errors/DuplicateSliceError');

// Create a simple test
const structDef = new StructureDefinition('Observation');
structDef.id = 'TestObservation';

// Add an element with slicing
const component = new ElementDefinition('Observation.component');
component.slicing = {
  discriminator: [{ type: 'value', path: 'code' }],
  ordered: false,
  rules: 'open'
};
structDef.addElement(component);

// Add first slice
try {
  const slice1 = component.addSlice('foo');
  console.log('✓ First slice "foo" added successfully');
} catch (e) {
  console.error('✗ Failed to add first slice:', e.message);
  process.exit(1);
}

// Try to add duplicate slice
try {
  const slice2 = component.addSlice('foo');
  console.error('✗ Should have thrown DuplicateSliceError but did not');
  process.exit(1);
} catch (e) {
  if (e instanceof DuplicateSliceError) {
    console.log('✓ Correctly threw DuplicateSliceError:', e.message);
  } else {
    console.error('✗ Threw wrong error type:', e.message);
    process.exit(1);
  }
}

console.log('\n✓ All tests passed!');
EOF

# [62]
cd /testbed && node /tmp/test_duplicate.js

# [63]
grep -A20 "describe.*addSlice" /testbed/test/fhirtypes/ElementDefinition.slicing.test.ts | head -30

# [64]
grep -B10 "describe.*#addSlice" /testbed/test/fhirtypes/ElementDefinition.slicing.test.ts | head -20

# [65]
grep -n "let observation" /testbed/test/fhirtypes/ElementDefinition.slicing.test.ts | head -5

# [66]
sed -n '1,50p' /testbed/test/fhirtypes/ElementDefinition.slicing.test.ts | grep -A10 "beforeEach"

# [67]
sed -n '1,20p' /testbed/test/fhirtypes/ElementDefinition.slicing.test.ts

# [68]
cd /testbed && npm test -- --testPathPattern="StructureDefinitionExporter" --no-coverage 2>&1 | grep -A5 -B5 "FAIL\|PASS" | tail -50

# [69]
grep -n "component contains" /testbed/test/export/StructureDefinitionExporter.test.ts | head -10

# [70]
grep -B10 -A20 "Parent.*A\|inherits" /testbed/test/export/StructureDefinitionExporter.test.ts | grep -A20 "contains" | head -50

# [71]
cat > /tmp/test_inheritance.js << 'EOF'
const path = require('path');
const { loadFromPath } = require('/testbed/dist/fhirdefs/load');
const { FHIRDefinitions } = require('/testbed/dist/fhirdefs/FHIRDefinitions');
const { StructureDefinition } = require('/testbed/dist/fhirtypes/StructureDefinition');
const { DuplicateSliceError } = require('/testbed/dist/errors/DuplicateSliceError');

// Load FHIR definitions
const defs = new FHIRDefinitions();
loadFromPath(
  path.join(__dirname, 'testbed/test/testhelpers/testdefs/package'),
  'testPackage',
  defs
);

// Get Observation structure definition
const observation = defs.fishForFHIR('Observation', 'StructureDefinition');
const obsStructDef = StructureDefinition.fromJSON(observation);

// Simulate Profile A - add slicing and a slice
const component = obsStructDef.elements.find(e => e.id === 'Observation.component');
component.sliceIt('pattern', 'code', false, 'open');
const fooSlice = component.addSlice('foo');
console.log('✓ Profile A: Added slice "foo" successfully');

// Now simulate Profile B inheriting from Profile A and trying to add the same slice again
try {
  const duplicateSlice = component.addSlice('foo');
  console.error('✗ Should have thrown DuplicateSliceError but did not');
  process.exit(1);
} catch (e) {
  if (e instanceof DuplicateSliceError) {
    console.log('✓ Profile B: Correctly threw DuplicateSliceError:', e.message);
    console.log('  Expected message format: Slice named foo already exists on element Observation.component of Observation');
  } else {
    console.error('✗ Threw wrong error type:', e.message);
    console.error('  Error stack:', e.stack);
    process.exit(1);
  }
}

console.log('\n✓ All inheritance tests passed!');
EOF

# [72]
cd /testbed && node /tmp/test_inheritance.js

# [73]
cat > /tmp/test_inheritance2.js << 'EOF'
const path = require('path');

// Add testbed to module paths
module.paths.unshift('/testbed/dist');

const { loadFromPath } = require('fhirdefs/load');
const { FHIRDefinitions } = require('fhirdefs/FHIRDefinitions');
const { StructureDefinition } = require('fhirtypes/StructureDefinition');
const { DuplicateSliceError } = require('errors/DuplicateSliceError');

async function runTest() {
  // Load FHIR definitions
  const defs = new FHIRDefinitions();
  await loadFromPath(
    path.join('/testbed/test/testhelpers/testdefs/package'),
    'testPackage',
    defs
  );

  // Get Observation structure definition
  const observationJSON = defs.fishForFHIR('Observation', 'StructureDefinition');
  const obsStructDef = StructureDefinition.fromJSON(observationJSON);
  
  console.log('Loaded Observation structure definition with', obsStructDef.elements.length, 'elements');

  // Simulate Profile A - add slicing and a slice
  const component = obsStructDef.elements.find(e => e.id === 'Observation.component');
  if (!component) {
    console.error('Could not find Observation.component element');
    process.exit(1);
  }
  
  component.sliceIt('pattern', 'code', false, 'open');
  const fooSlice = component.addSlice('foo');
  console.log('✓ Profile A: Added slice "foo" successfully');
  console.log('  Slice ID:', fooSlice.id);
  console.log('  Slice name:', fooSlice.sliceName);

  // Verify the slice exists
  const slices = component.getSlices();
  console.log('  Total slices:', slices.length);

  // Now simulate Profile B inheriting from Profile A and trying to add the same slice again
  try {
    const duplicateSlice = component.addSlice('foo');
    console.error('✗ Should have thrown DuplicateSliceError but did not');
    process.exit(1);
  } catch (e) {
    if (e instanceof DuplicateSliceError) {
      console.log('\n✓ Profile B: Correctly threw DuplicateSliceError');
      console.log('  Message:', e.message);
      console.log('  Expected: Slice named foo already exists on element Observation.component of Observation');
      
      // Verify the message matches expected format
      const expectedMessage = 'Slice named foo already exists on element Observation.component of Observation';
      if (e.message === expectedMessage) {
        console.log('  ✓ Message format is correct!');
      } else {
        console.error('  ✗ Message format mismatch!');
        process.exit(1);
      }
    } else {
      console.error('✗ Threw wrong error type:', e.constructor.name);
      console.error('  Message:', e.message);
      console.error('  Stack:', e.stack);
      process.exit(1);
    }
  }

  console.log('\n✓ All inheritance tests passed!');
}

runTest().catch(err => {
  console.error('Test failed with error:', err);
  process.exit(1);
});
EOF

# [74]
cd /testbed && node /tmp/test_inheritance2.js

# [75]
cat > /tmp/test_simple.js << 'EOF'
const path = require('path');
module.paths.unshift('/testbed/dist');

const { loadFromPath } = require('fhirdefs/load');
const { FHIRDefinitions } = require('fhirdefs/FHIRDefinitions');
const { StructureDefinition } = require('fhirtypes/StructureDefinition');

async function runTest() {
  const defs = new FHIRDefinitions();
  await loadFromPath(
    path.join('/testbed/test/testhelpers/testdefs/package'),
    'testPackage',
    defs
  );

  const observationJSON = defs.fishForFHIR('Observation');
  console.log('Type of observationJSON:', typeof observationJSON);
  console.log('Has resourceType:', observationJSON?.resourceType);
  console.log('Has id:', observationJSON?.id);
  
  if (observationJSON) {
    const obsStructDef = StructureDefinition.fromJSON(observationJSON);
    console.log('\n✓ Successfully created StructureDefinition');
    console.log('Elements count:', obsStructDef.elements.length);
    
    // Find component element
    const component = obsStructDef.elements.find(e => e.id === 'Observation.component');
    console.log('Found component:', !!component);
    
    if (component) {
      // Add slicing
      component.sliceIt('pattern', 'code', false, 'open');
      console.log('✓ Added slicing to component');
      
      // Add first slice
      const slice1 = component.addSlice('foo');
      console.log('✓ Added first slice "foo":', slice1.id);
      
      // Try to add duplicate
      try {
        const slice2 = component.addSlice('foo');
        console.error('✗ Should have thrown error for duplicate slice');
        process.exit(1);
      } catch (e) {
        console.log('✓ Correctly threw error:', e.message);
        if (e.constructor.name === 'DuplicateSliceError') {
          console.log('✓ Error is DuplicateSliceError');
        } else {
          console.error('✗ Wrong error type:', e.constructor.name);
          process.exit(1);
        }
      }
    }
  }
}

runTest().catch(err => {
  console.error('Failed:', err.message);
  console.error(err.stack);
  process.exit(1);
});
EOF

# [76]
cd /testbed && node /tmp/test_simple.js 2>&1 | grep -v "Warning:"

# [77]
cd /testbed && npm test -- --no-coverage 2>&1 | tail -100

# [78]
grep "DuplicateSliceError" /testbed/dist/errors/index.js

# [79]
cat > /tmp/test_pr_scenario.js << 'EOF'
const path = require('path');
module.paths.unshift('/testbed/dist');

const { loadFromPath } = require('fhirdefs/load');
const { FHIRDefinitions } = require('fhirdefs/FHIRDefinitions');
const { StructureDefinition } = require('fhirtypes/StructureDefinition');
const { DuplicateSliceError } = require('errors/DuplicateSliceError');

async function runTest() {
  console.log('Testing PR scenario: Repeated Slices are Allowed\n');
  console.log('=' .repeat(60));
  
  const defs = new FHIRDefinitions();
  await loadFromPath(
    path.join('/testbed/test/testhelpers/testdefs/package'),
    'testPackage',
    defs
  );

  const observationJSON = defs.fishForFHIR('Observation');
  const obsStructDef = StructureDefinition.fromJSON(observationJSON);
  
  // Profile A: Create profile with component containing foo slice
  console.log('\n1. Creating Profile A (parent profile)');
  console.log('-'.repeat(60));
  const profileA = obsStructDef.clone();
  profileA.id = 'ProfileA';
  profileA.name = 'ProfileA';
  
  const component = profileA.elements.find(e => e.id === 'Observation.component');
  component.sliceIt('pattern', 'code', false, 'open');
  
  try {
    const fooSlice = component.addSlice('foo');
    console.log('✓ Profile A: Added "component contains foo 0..1"');
    console.log('  - Slice ID:', fooSlice.id);
    console.log('  - Slice name:', fooSlice.sliceName);
  } catch (e) {
    console.error('✗ Failed to add slice in Profile A:', e.message);
    process.exit(1);
  }
  
  // Verify snapshot has the slice
  const slicesInA = component.getSlices();
  console.log('  - Total slices in Profile A:', slicesInA.length);
  
  // Profile B: Try to inherit from A and incorrectly slice component again with foo
  console.log('\n2. Creating Profile B (child profile inheriting from A)');
  console.log('-'.repeat(60));
  const profileB = profileA.clone();
  profileB.id = 'ProfileB';
  profileB.name = 'ProfileB';
  
  const componentB = profileB.elements.find(e => e.id === 'Observation.component');
  
  // This simulates: * component contains foo 1..1
  // Which is incorrect since foo already exists
  console.log('Attempting: "component contains foo 1..1" (incorrect - foo already exists)');
  
  try {
    const duplicateFooSlice = componentB.addSlice('foo');
    console.error('✗ ERROR: Should have thrown DuplicateSliceError but did not!');
    console.error('  This would create duplicate Observation.component:foo elements');
    
    // Check if we now have duplicates
    const slicesInB = componentB.getSlices();
    console.error('  - Total slices in Profile B:', slicesInB.length);
    const fooSlices = slicesInB.filter(s => s.sliceName === 'foo');
    console.error('  - Number of "foo" slices:', fooSlices.length);
    if (fooSlices.length > 1) {
      console.error('  ✗ DUPLICATE SLICES DETECTED!');
    }
    process.exit(1);
  } catch (e) {
    if (e instanceof DuplicateSliceError) {
      console.log('✓ Correctly prevented duplicate slice creation');
      console.log('  - Error type:', e.constructor.name);
      console.log('  - Error message:', e.message);
      
      // Verify the error message format matches the PR description
      const expectedPattern = /Slice named foo already exists on element Observation\.component of ProfileB/;
      if (expectedPattern.test(e.message)) {
        console.log('  ✓ Error message format is correct');
      } else {
        console.error('  ✗ Error message format does not match expected pattern');
        process.exit(1);
      }
      
      // Verify no duplicate was created
      const slicesInB = componentB.getSlices();
      const fooSlices = slicesInB.filter(s => s.sliceName === 'foo');
      if (fooSlices.length === 1) {
        console.log('  ✓ No duplicate slice was created (still only 1 "foo" slice)');
      } else {
        console.error('  ✗ Unexpected number of "foo" slices:', fooSlices.length);
        process.exit(1);
      }
    } else {
      console.error('✗ Threw wrong error type:', e.constructor.name);
      console.error('  Message:', e.message);
      process.exit(1);
    }
  }
  
  console.log('\n' + '='.repeat(60));
  console.log('✓ All tests passed! The fix correctly prevents duplicate slices.');
  console.log('='.repeat(60));
}

runTest().catch(err => {
  console.error('\n✗ Test failed with error:', err.message);
  console.error(err.stack);
  process.exit(1);
});
EOF

# [80]
cd /testbed && node /tmp/test_pr_scenario.js 2>&1 | grep -v "Warning:"

# [81]
grep -n "clone" /testbed/src/fhirtypes/StructureDefinition.ts | head -10

# [82]
cat > /tmp/test_final.js << 'EOF'
const path = require('path');
module.paths.unshift('/testbed/dist');

const { loadFromPath } = require('fhirdefs/load');
const { FHIRDefinitions } = require('fhirdefs/FHIRDefinitions');
const { StructureDefinition } = require('fhirtypes/StructureDefinition');
const { DuplicateSliceError } = require('errors/DuplicateSliceError');

async function runTest() {
  console.log('Testing PR scenario: Repeated Slices Prevention\n');
  console.log('=' .repeat(60));
  
  const defs = new FHIRDefinitions();
  await loadFromPath(
    path.join('/testbed/test/testhelpers/testdefs/package'),
    'testPackage',
    defs
  );

  const observationJSON = defs.fishForFHIR('Observation');
  const obsStructDef = StructureDefinition.fromJSON(observationJSON);
  
  // Profile A: Create profile with component containing foo slice
  console.log('\n1. Simulating Profile A: Adding "component contains foo 0..1"');
  console.log('-'.repeat(60));
  
  const component = obsStructDef.elements.find(e => e.id === 'Observation.component');
  component.sliceIt('pattern', 'code', false, 'open');
  
  try {
    const fooSlice = component.addSlice('foo');
    console.log('✓ Successfully added slice "foo"');
    console.log('  - Slice ID:', fooSlice.id);
    console.log('  - Slice name:', fooSlice.sliceName);
    console.log('  - StructureDefinition:', obsStructDef.id);
  } catch (e) {
    console.error('✗ Failed to add slice:', e.message);
    process.exit(1);
  }
  
  // Verify the slice exists
  const slicesAfterFirst = component.getSlices();
  console.log('  - Total slices:', slicesAfterFirst.length);
  
  // Now try to add the same slice again (simulating incorrect Profile B)
  console.log('\n2. Simulating Profile B: Attempting "component contains foo 1..1"');
  console.log('   (This is incorrect since foo already exists from parent)');
  console.log('-'.repeat(60));
  
  try {
    const duplicateFooSlice = component.addSlice('foo');
    console.error('✗ FAILED: Should have thrown DuplicateSliceError!');
    console.error('  This would create duplicate Observation.component:foo elements');
    
    const slicesAfterSecond = component.getSlices();
    const fooSlices = slicesAfterSecond.filter(s => s.sliceName === 'foo');
    console.error('  - Number of "foo" slices:', fooSlices.length);
    if (fooSlices.length > 1) {
      console.error('  ✗ DUPLICATE SLICES WERE CREATED!');
    }
    process.exit(1);
  } catch (e) {
    if (e instanceof DuplicateSliceError) {
      console.log('✓ SUCCESS: Correctly prevented duplicate slice creation');
      console.log('  - Error type:', e.constructor.name);
      console.log('  - Error message:', e.message);
      
      // Verify error properties
      console.log('\n3. Verifying error properties:');
      console.log('-'.repeat(60));
      console.log('  - structDef:', e.structDef);
      console.log('  - element:', e.element);
      console.log('  - slice:', e.slice);
      console.log('  - specReferences:', e.specReferences);
      
      // Verify no duplicate was created
      const finalSlices = component.getSlices();
      const finalFooSlices = finalSlices.filter(s => s.sliceName === 'foo');
      console.log('\n4. Verifying no duplicate in structure:');
      console.log('-'.repeat(60));
      console.log('  - Total slices:', finalSlices.length);
      console.log('  - "foo" slices count:', finalFooSlices.length);
      
      if (finalFooSlices.length === 1) {
        console.log('  ✓ Only one "foo" slice exists (no duplicate created)');
      } else {
        console.error('  ✗ Unexpected number of "foo" slices:', finalFooSlices.length);
        process.exit(1);
      }
      
    } else {
      console.error('✗ Threw wrong error type:', e.constructor.name);
      console.error('  Message:', e.message);
      process.exit(1);
    }
  }
  
  console.log('\n' + '='.repeat(60));
  console.log('✓ ALL TESTS PASSED!');
  console.log('The fix correctly prevents duplicate slice definitions.');
  console.log('='.repeat(60));
}

runTest().catch(err => {
  console.error('\n✗ Test failed with error:', err.message);
  console.error(err.stack);
  process.exit(1);
});
EOF

# [83]
cd /testbed && node /tmp/test_final.js 2>&1 | grep -v "Warning:"

# [84]
cat > /tmp/test_edge_cases.js << 'EOF'
const path = require('path');
module.paths.unshift('/testbed/dist');

const { loadFromPath } = require('fhirdefs/load');
const { FHIRDefinitions } = require('fhirdefs/FHIRDefinitions');
const { StructureDefinition } = require('fhirtypes/StructureDefinition');
const { DuplicateSliceError } = require('errors/DuplicateSliceError');

async function runTest() {
  console.log('Testing Edge Cases\n');
  console.log('=' .repeat(60));
  
  const defs = new FHIRDefinitions();
  await loadFromPath(
    path.join('/testbed/test/testhelpers/testdefs/package'),
    'testPackage',
    defs
  );

  const observationJSON = defs.fishForFHIR('Observation');
  const obsStructDef = StructureDefinition.fromJSON(observationJSON);
  
  const component = obsStructDef.elements.find(e => e.id === 'Observation.component');
  component.sliceIt('pattern', 'code', false, 'open');
  
  // Test 1: Adding multiple different slices should work
  console.log('\n1. Testing multiple different slices');
  console.log('-'.repeat(60));
  try {
    const slice1 = component.addSlice('slice1');
    const slice2 = component.addSlice('slice2');
    const slice3 = component.addSlice('slice3');
    console.log('✓ Successfully added 3 different slices');
    console.log('  - Slices:', [slice1.sliceName, slice2.sliceName, slice3.sliceName].join(', '));
  } catch (e) {
    console.error('✗ Failed to add different slices:', e.message);
    process.exit(1);
  }
  
  // Test 2: Trying to duplicate any of them should fail
  console.log('\n2. Testing duplicate detection for each slice');
  console.log('-'.repeat(60));
  ['slice1', 'slice2', 'slice3'].forEach(sliceName => {
    try {
      component.addSlice(sliceName);
      console.error(`✗ Should have thrown error for duplicate "${sliceName}"`);
      process.exit(1);
    } catch (e) {
      if (e instanceof DuplicateSliceError) {
        console.log(`✓ Correctly prevented duplicate "${sliceName}"`);
      } else {
        console.error(`✗ Wrong error type for "${sliceName}":`, e.constructor.name);
        process.exit(1);
      }
    }
  });
  
  // Test 3: Verify all original slices still exist
  console.log('\n3. Verifying all original slices still exist');
  console.log('-'.repeat(60));
  const allSlices = component.getSlices();
  console.log('  - Total slices:', allSlices.length);
  console.log('  - Slice names:', allSlices.map(s => s.sliceName).join(', '));
  
  if (allSlices.length === 3) {
    console.log('  ✓ All 3 slices present and no duplicates created');
  } else {
    console.error('  ✗ Unexpected number of slices:', allSlices.length);
    process.exit(1);
  }
  
  console.log('\n' + '='.repeat(60));
  console.log('✓ ALL EDGE CASE TESTS PASSED!');
  console.log('='.repeat(60));
}

runTest().catch(err => {
  console.error('\n✗ Test failed with error:', err.message);
  console.error(err.stack);
  process.exit(1);
});
EOF

# [85]
cd /testbed && node /tmp/test_edge_cases.js 2>&1 | grep -v "Warning:"

# [86]
cd /testbed && npm test -- --no-coverage 2>&1 | grep -E "Test Suites:|Tests:" | tail -2

# [87]
cat > /tmp/implementation_summary.md << 'EOF'
# Implementation Summary: DuplicateSliceError

## Changes Made

### 1. Created DuplicateSliceError class
**File**: `src/errors/DuplicateSliceError.ts`

Created a new error class that is thrown when attempting to add a slice that already exists on an element. The error includes:
- `structDef`: The name/id of the StructureDefinition
- `element`: The full path of the element where the duplicate is being added
- `slice`: The name of the slice being duplicated
- Error message format: `Slice named ${slice} already exists on element ${element} of ${structDef}`
- Reference to FHIR specification on slicing

### 2. Exported DuplicateSliceError
**File**: `src/errors/index.ts`

Added export statement for the new DuplicateSliceError class.

### 3. Modified ElementDefinition.addSlice method
**File**: `src/fhirtypes/ElementDefinition.ts`

- Added import for DuplicateSliceError
- Modified the `addSlice` method to check if a slice with the given name already exists before creating it
- Uses the existing `getSlices()` method to find all slices on the element
- Throws DuplicateSliceError if a slice with the same name is found

## How it Works

When a ContainsRule tries to add a slice using `element.addSlice(name)`, the method now:

1. Checks if slicing is defined (existing behavior)
2. **NEW**: Retrieves all existing slices on the element
3. **NEW**: Searches for a slice with the same name
4. **NEW**: If found, throws DuplicateSliceError with descriptive message
5. If not found, proceeds with slice creation (existing behavior)

## Benefits

This implementation prevents the issue described in the PR where:
- Profile A defines a slice (e.g., `component contains foo 0..1`)
- Profile B inherits from A and incorrectly tries to redefine the same slice (e.g., `component contains foo 1..1`)
- Previously, this would create duplicate `Observation.component:foo` elements in both snapshot and differential
- Now, it throws a clear error indicating the slice already exists

The error is caught by the exporter and logged appropriately, providing users with clear feedback about the mistake.

## Testing

All existing tests pass (65 test suites, 1183 tests).

Manual testing confirms:
- First slice addition works correctly
- Duplicate slice attempt throws DuplicateSliceError
- Error message matches expected format
- No duplicate slices are created in the structure
- Multiple different slices can still be added without issues
EOF
cat /tmp/implementation_summary.md

# [88]
cd /testbed && git diff src/errors/DuplicateSliceError.ts src/errors/index.ts src/fhirtypes/ElementDefinition.ts > patch.txt

# [89]
cat patch.txt

# [90]
cd /testbed && git status src/errors/DuplicateSliceError.ts

# [91]
cd /testbed && git add src/errors/DuplicateSliceError.ts && git diff --cached src/errors/DuplicateSliceError.ts >> patch.txt

# [92]
cat patch.txt | tail -30

# [93]
head -80 patch.txt

# [94]
cd /testbed && npm test -- --no-coverage 2>&1 | tail -5
