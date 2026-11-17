#!/usr/bin/env bash
# alangpierce__sucrase-800，共 132 条命令，按轨迹原顺序执行

# [1]
ln -sfn /sucrase /testbed && ls /testbed | head -3; go clean -cache 2>/dev/null; rm -rf /testbed/target /testbed/dist /testbed/build /testbed/out /testbed/.gradle /testbed/node_modules/.cache 2>/dev/null; find /testbed -name '__pycache__' -type d -prune -exec rm -rf {} + 2>/dev/null; find /testbed -name '*.tsbuildinfo' -delete 2>/dev/null; find /testbed -name '*.o' -delete 2>/dev/null; true; rm -rf /tmp/jest_* /testbed/node_modules/.vite /testbed/.parcel-cache /testbed/.eslintcache 2>/dev/null; true

# [2]
ls -la

# [3]
find src -type f -name "*.ts" -o -name "*.js" | head -20

# [4]
ls -la src/

# [5]
ls -la src/transformers/

# [6]
cat > reproduce_issue.js << 'EOF'
const sucrase = require("./dist/index");

// Test TypeScript
const tsCode = `class Foo {
  constructor(): Foo {
    return this;
  }
}`;

console.log("=== TypeScript Input ===");
console.log(tsCode);
console.log("\n=== TypeScript Output ===");
const tsResult = sucrase.transform(tsCode, { transforms: ["typescript"] });
console.log(tsResult.code);

// Test Flow
const flowCode = `class Foo {
  constructor(): Foo {
    return this;
  }
}`;

console.log("\n=== Flow Input ===");
console.log(flowCode);
console.log("\n=== Flow Output ===");
const flowResult = sucrase.transform(flowCode, { transforms: ["flow"] });
console.log(flowResult.code);
EOF

# [7]
node reproduce_issue.js

# [8]
cat src/transformers/TypeScriptTransformer.ts

# [9]
cat src/transformers/FlowTransformer.ts

# [10]
cat src/transformers/RootTransformer.ts | head -200

# [11]
grep -n "processPossibleTypeRange" src/transformers/RootTransformer.ts

# [12]
sed -n '435,500p' src/transformers/RootTransformer.ts

# [13]
grep -n "processClass" src/transformers/RootTransformer.ts | head -20

# [14]
sed -n '221,350p' src/transformers/RootTransformer.ts

# [15]
cat src/util/getClassInfo.ts | head -100

# [16]
grep -n "processConstructor" src/util/getClassInfo.ts

# [17]
sed -n '246,350p' src/util/getClassInfo.ts

# [18]
cat > test_tokens.js << 'EOF'
const {parse} = require("./dist/parser/index");

const code = `class Foo {
  constructor(): Foo {
    return this;
  }
}`;

const result = parse(code, {
  transforms: ["typescript"],
  filePath: "test.ts",
  enableLegacyBabel5TypeScriptModuleInterop: false,
  enableLegacyTypeScriptModuleInterop: false,
  jsxRuntime: "automatic",
  reactHotLoaderTransformer: null,
  tokenize: true,
});

console.log("Tokens:");
result.tokens.forEach((token, i) => {
  console.log(`${i}: ${token.type} "${token.value}" isType=${token.isType}`);
});
EOF

# [19]
node test_tokens.js 2>&1 | head -50

# [20]
cat > test_tokens2.js << 'EOF'
const sucrase = require("./dist/index");

const code = `class Foo {
  constructor(): Foo {
    return this;
  }
}`;

// Use the internal API to get tokens
const {parse} = require("./dist/parser/tokenizer/index");
const {JSDocParser} = require("./dist/parser/plugins/jsdocPlugin");

try {
  const result = parse(code, {
    isJSX: false,
    isFlow: false,
    isTSX: false,
    isTypeScript: true,
    earlyErrors: false,
  });
  
  console.log("Tokens around constructor:");
  result.tokens.forEach((token, i) => {
    if (i >= 3 && i <= 15) {
      console.log(`${i}: type=${token.type}, value="${token.value}", isType=${token.isType}`);
    }
  });
} catch (e) {
  console.error("Error:", e.message);
}
EOF

# [21]
node test_tokens2.js 2>&1

# [22]
ls -la src/parser/

# [23]
find test -name "*.js" -o -name "*.ts" | grep -i constructor | head -5

# [24]
find test -type f | head -20

# [25]
grep -n "constructor" test/typescript-test.ts | head -20

# [26]
grep -n "constructor.*:" test/typescript-test.ts | head -20

# [27]
sed -n '193,220p' src/transformers/RootTransformer.ts

# [28]
find src/parser -name "*.ts" -exec grep -l "returnType" {} \;

# [29]
find src/parser -name "*.ts" | head -20

# [30]
grep -n "constructor" src/parser/plugins/typescript.ts | head -20

# [31]
sed -n '315,340p' src/parser/plugins/typescript.ts

# [32]
grep -n "colon" src/parser/plugins/typescript.ts | head -20

# [33]
grep -n "tsFillSignature" src/parser/plugins/typescript.ts

# [34]
sed -n '243,260p' src/parser/plugins/typescript.ts

# [35]
grep -n "tsParseTypeOrTypePredicateAnnotation" src/parser/plugins/typescript.ts

# [36]
sed -n '674,700p' src/parser/plugins/typescript.ts

# [37]
grep -n "pushTypeContext" src/parser/plugins/types.ts

# [38]
grep -rn "pushTypeContext" src/parser/

# [39]
sed -n '192,210p' src/parser/tokenizer/index.ts

# [40]
grep -n "^function expect" src/parser/traverser/util.ts

# [41]
grep -n "export function expect" src/parser/traverser/util.ts

# [42]
sed -n '83,95p' src/parser/traverser/util.ts

# [43]
grep -n "^export function next" src/parser/tokenizer/index.ts

# [44]
sed -n '171,190p' src/parser/tokenizer/index.ts

# [45]
grep -n "class Token" src/parser/tokenizer/index.ts

# [46]
sed -n '111,165p' src/parser/tokenizer/index.ts

# [47]
grep -n "parseClassMethod" src/parser/traverser/statement.ts

# [48]
sed -n '881,950p' src/parser/traverser/statement.ts

# [49]
grep -n "^function parseMethod" src/parser/traverser/expression.ts

# [50]
grep -n "export function parseMethod" src/parser/traverser/expression.ts

# [51]
sed -n '918,970p' src/parser/traverser/expression.ts

# [52]
grep -n "tsParseFunctionBodyAndFinish" src/parser/plugins/typescript.ts

# [53]
sed -n '1202,1230p' src/parser/plugins/typescript.ts

# [54]
grep -n "flowParseFunctionBodyAndFinish" src/parser/plugins/flow.ts

# [55]
sed -n '716,750p' src/parser/plugins/flow.ts

# [56]
grep -n "flowParseTypeAndPredicateInitialiser" src/parser/plugins/flow.ts

# [57]
sed -n '73,90p' src/parser/plugins/flow.ts

# [58]
sed -n '830,850p' src/parser/traverser/statement.ts

# [59]
cat > debug_tokens.js << 'EOF'
const {transform} = require("./dist/index");

const code = `class Foo {
  constructor(): Foo {
    return this;
  }
}`;

// Transform with debugging
const result = transform(code, { 
  transforms: ["typescript"],
  enableLegacyTypeScriptModuleInterop: false,
});

console.log("Input:");
console.log(code);
console.log("\nOutput:");
console.log(result.code);
console.log("\nCharacter codes around constructor:");
const outputLines = result.code.split('\n');
const constructorLine = outputLines[1];
console.log("Line:", constructorLine);
for (let i = 0; i < constructorLine.length; i++) {
  console.log(`  ${i}: '${constructorLine[i]}' (${constructorLine.charCodeAt(i)})`);
}
EOF

# [60]
node debug_tokens.js

# [61]
grep -n "isConstructor" src/parser/plugins/typescript.ts

# [62]
grep -n "isConstructor" src/parser/plugins/flow.ts

# [63]
grep -n "export function parseFunctionParams" src/parser/traverser/expression.ts

# [64]
grep -n "parseFunctionParams" src/parser/traverser/expression.ts | head -5

# [65]
grep -n "^export function parseFunctionParams" src/parser/traverser/lval.ts

# [66]
grep -n "function parseFunctionParams" src/parser/traverser/lval.ts

# [67]
grep -rn "function parseFunctionParams" src/parser/

# [68]
sed -n '689,750p' src/parser/traverser/statement.ts

# [69]
grep -B5 -A10 "ContextualKeyword._constructor" src/parser/traverser/statement.ts | head -40

# [70]
grep -rn "constructor.*:.*{" test/ | grep -E "(typescript|flow)" | head -10

# [71]
grep -n "tsStartParseFunctionParams" src/parser/plugins/typescript.ts

# [72]
sed -n '1521,1540p' src/parser/plugins/typescript.ts

# [73]
grep -i "constructor" src/parser/plugins/typescript.ts

# [74]
sed -n '435,445p' src/transformers/RootTransformer.ts

# [75]
grep -n "function isClassMethod" src/parser/traverser/statement.ts

# [76]
sed -n '754,780p' src/parser/traverser/statement.ts

# [77]
cat > test_method_return.js << 'EOF'
const sucrase = require("./dist/index");

// Test regular method with return type
const code = `class Foo {
  bar(): string {
    return "hello";
  }
}`;

console.log("Input:");
console.log(code);
console.log("\nOutput:");
const result = sucrase.transform(code, { transforms: ["typescript"] });
console.log(result.code);
EOF

# [78]
node test_method_return.js

# [79]
grep -rn "constructor" src/transformers/ | grep -v "// " | head -20

# [80]
sed -n '246,305p' src/util/getClassInfo.ts

# [81]
sed -n '221,248p' src/transformers/RootTransformer.ts

# [82]
grep -n "restoreFromSnapshot" src/util/getClassInfo.ts

# [83]
tail -20 src/util/getClassInfo.ts

# [84]
sed -n '180,245p' src/util/getClassInfo.ts

# [85]
grep -n "rangesToRemove.push" src/util/getClassInfo.ts

# [86]
sed -n '150,165p' src/util/getClassInfo.ts

# [87]
sed -n '278,285p' src/util/getClassInfo.ts

# [88]
cat > fix.patch << 'EOF'
--- a/src/util/getClassInfo.ts
+++ b/src/util/getClassInfo.ts
@@ -278,6 +278,11 @@ function processConstructor(tokens: TokenProcessor): {
   }
   // )
   tokens.nextToken();
+  // Skip any return type annotation like ": Foo"
+  while (tokens.currentToken().isType) {
+    tokens.nextToken();
+  }
+
   let constructorInsertPos = tokens.currentIndex();
 
   // Advance through body looking for a super call.
EOF

# [89]
patch -p1 < fix.patch

# [90]
npm run build 2>&1 | tail -20

# [91]
npx tsc 2>&1 | head -30

# [92]
node reproduce_issue.js

# [93]
cat > test_isType.js << 'EOF'
const {parse} = require("./dist/parser/index");

const code = `class Foo {
  constructor(): Foo {
    return this;
  }
}`;

const result = parse(code, {
  isJSX: false,
  isFlow: false,
  isTSX: false,
  isTypeScript: true,
  earlyErrors: false,
});

console.log("All tokens:");
result.tokens.forEach((token, i) => {
  const value = code.slice(token.start, token.end);
  console.log(`${i}: type=${String(token.type).padEnd(20)} value="${value.padEnd(10)}" isType=${token.isType}`);
});
EOF

# [94]
node test_isType.js 2>&1 | grep -A2 -B2 "constructor"

# [95]
node test_isType.js 2>&1

# [96]
cat > test.ts << 'EOF'
class Foo {
  constructor(): Foo {
    return this;
  }
}
EOF

# [97]
npx tsc --noEmit test.ts 2>&1

# [98]
cat > test_parse2.js << 'EOF'
const {parse} = require("./dist/parser/index");

const code = `class Foo {
  constructor(): Foo {
    return this;
  }
}`;

// Try without TypeScript
try {
  const result = parse(code, {
    isJSX: false,
    isFlow: false,
    isTSX: false,
    isTypeScript: false,
    earlyErrors: false,
  });
  console.log("Parsed successfully without TypeScript!");
  console.log("Tokens around constructor:");
  result.tokens.forEach((token, i) => {
    if (i >= 3 && i <= 15) {
      const value = code.slice(token.start, token.end);
      console.log(`${i}: type=${String(token.type).padEnd(20)} value="${value}"`);
    }
  });
} catch (e) {
  console.log("Failed without TypeScript:", e.message);
}
EOF

# [99]
node test_parse2.js

# [100]
cat reproduce_issue.js

# [101]
grep -A30 "export function transform" src/index.ts | head -40

# [102]
grep -A50 "function getSucraseContext" src/index.ts | head -60

# [103]
cat src/parser/index.ts

# [104]
node reproduce_issue.js 2>&1

# [105]
cat > debug_transform.js << 'EOF'
const sucrase = require("./dist/index");

const code = `class Foo {
  constructor(): Foo {
    return this;
  }
}`;

// Monkey-patch to add debugging
const originalTransform = sucrase.transform;
sucrase.transform = function(code, options) {
  console.log("Transforming with options:", JSON.stringify(options, null, 2));
  try {
    const result = originalTransform.call(this, code, options);
    console.log("Transformation successful");
    return result;
  } catch (e) {
    console.log("Transformation failed:", e.message);
    throw e;
  }
};

const result = sucrase.transform(code, { transforms: ["typescript"] });
console.log("\nOutput:");
console.log(result.code);
EOF

# [106]
node debug_transform.js

# [107]
grep -A5 "Skip any return type" dist/util/getClassInfo.js

# [108]
npx tsc --project tsconfig.json 2>&1 | grep -i error | head -10

# [109]
grep -A5 "Skip any return type" dist/util/getClassInfo.js

# [110]
ls -la dist/util/getClassInfo.js

# [111]
cat tsconfig.json

# [112]
cat package.json | grep -A10 '"scripts"'

# [113]
./node_modules/.bin/sucrase-node script/build.ts --fast 2>&1 | tail -30

# [114]
grep -A5 "Skip any return type" dist/util/getClassInfo.js

# [115]
node reproduce_issue.js

# [116]
cat > test_edge_cases.js << 'EOF'
const sucrase = require("./dist/index");

const testCases = [
  {
    name: "Constructor with return type",
    code: `class Foo {
  constructor(): Foo {
    return this;
  }
}`
  },
  {
    name: "Constructor with complex return type",
    code: `class Foo {
  constructor(): Foo | null {
    return this;
  }
}`
  },
  {
    name: "Constructor with generic return type",
    code: `class Foo<T> {
  constructor(): Foo<T> {
    return this;
  }
}`
  },
  {
    name: "Regular method with return type (should still work)",
    code: `class Foo {
  bar(): string {
    return "hello";
  }
}`
  },
  {
    name: "Constructor with parameters and return type",
    code: `class Foo {
  constructor(x: number): Foo {
    this.x = x;
  }
}`
  },
  {
    name: "Constructor without return type (should still work)",
    code: `class Foo {
  constructor(x: number) {
    this.x = x;
  }
}`
  }
];

for (const testCase of testCases) {
  console.log(`\n=== ${testCase.name} ===`);
  console.log("Input:");
  console.log(testCase.code);
  try {
    const result = sucrase.transform(testCase.code, { transforms: ["typescript"] });
    console.log("\nOutput:");
    console.log(result.code);
  } catch (e) {
    console.log("\nError:", e.message);
  }
}
EOF

# [117]
node test_edge_cases.js

# [118]
cat > test_flow.js << 'EOF'
const sucrase = require("./dist/index");

const testCases = [
  {
    name: "Flow constructor with return type",
    code: `class Foo {
  constructor(): Foo {
    return this;
  }
}`
  },
  {
    name: "Flow constructor with complex return type",
    code: `class Foo {
  constructor(): Foo | null {
    return this;
  }
}`
  }
];

for (const testCase of testCases) {
  console.log(`\n=== ${testCase.name} ===`);
  console.log("Input:");
  console.log(testCase.code);
  try {
    const result = sucrase.transform(testCase.code, { transforms: ["flow"] });
    console.log("\nOutput:");
    console.log(result.code);
  } catch (e) {
    console.log("\nError:", e.message);
  }
}
EOF

# [119]
node test_flow.js

# [120]
npm test 2>&1 | tail -50

# [121]
./node_modules/.bin/mocha --require sucrase-register test/*-test.ts 2>&1 | tail -100

# [122]
cat .mocharc.js

# [123]
./node_modules/.bin/mocha --require ./register/index.js test/*-test.ts 2>&1 | tail -100

# [124]
cat > test_constructor_return_type.js << 'EOF'
const sucrase = require("./dist/index");

// Test case from the PR description
const tsCode = `class Foo {
  constructor(): Foo {
    return this;
  }
}`;

const flowCode = `class Foo {
  constructor(): Foo {
    return this;
  }
}`;

console.log("Testing TypeScript constructor return type...");
const tsResult = sucrase.transform(tsCode, { transforms: ["typescript"] });
const expectedTS = `class Foo {
  constructor() {
    return this;
  }
}`;

if (tsResult.code === expectedTS) {
  console.log("✓ TypeScript test passed!");
} else {
  console.log("✗ TypeScript test failed!");
  console.log("Expected:", JSON.stringify(expectedTS));
  console.log("Got:", JSON.stringify(tsResult.code));
  process.exit(1);
}

console.log("\nTesting Flow constructor return type...");
const flowResult = sucrase.transform(flowCode, { transforms: ["flow"] });
const expectedFlow = `class Foo {
  constructor() {
    return this;
  }
}`;

if (flowResult.code === expectedFlow) {
  console.log("✓ Flow test passed!");
} else {
  console.log("✗ Flow test failed!");
  console.log("Expected:", JSON.stringify(expectedFlow));
  console.log("Got:", JSON.stringify(flowResult.code));
  process.exit(1);
}

console.log("\n✓ All tests passed!");
EOF

# [125]
node test_constructor_return_type.js

# [126]
cat src/util/getClassInfo.ts | grep -A10 -B5 "Skip any return type"

# [127]
grep -n "tokens.nextToken()" src/util/getClassInfo.ts | head -20

# [128]
grep -n "function process" src/util/getClassInfo.ts

# [129]
git diff src/util/getClassInfo.ts

# [130]
git diff src/util/getClassInfo.ts > patch.txt

# [131]
cat patch.txt

# [132]
node reproduce_issue.js
