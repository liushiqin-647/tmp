#!/usr/bin/env bash
# alangpierce__sucrase-800，共 132 条命令，按轨迹原顺序执行
# 控制台只打印每条命令的退出码和耗时；命令输出写到 /tmp/traj-run_sucrase_800/step-<序号>.log
LOG_DIR="${LOG_DIR:-/tmp/traj-run_sucrase_800}"
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
ln -sfn /sucrase /testbed && ls /testbed | head -3; go clean -cache 2>/dev/null; rm -rf /testbed/target /testbed/dist /testbed/build /testbed/out /testbed/.gradle /testbed/node_modules/.cache 2>/dev/null; find /testbed -name '__pycache__' -type d -prune -exec rm -rf {} + 2>/dev/null; find /testbed -name '*.tsbuildinfo' -delete 2>/dev/null; find /testbed -name '*.o' -delete 2>/dev/null; true; rm -rf /tmp/jest_* /testbed/node_modules/.vite /testbed/.parcel-cache /testbed/.eslintcache 2>/dev/null; true
__STEP_CMD__

run 2 <<'__STEP_CMD__'
ls -la
__STEP_CMD__

run 3 <<'__STEP_CMD__'
find src -type f -name "*.ts" -o -name "*.js" | head -20
__STEP_CMD__

run 4 <<'__STEP_CMD__'
ls -la src/
__STEP_CMD__

run 5 <<'__STEP_CMD__'
ls -la src/transformers/
__STEP_CMD__

run 6 <<'__STEP_CMD__'
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
__STEP_CMD__

run 7 <<'__STEP_CMD__'
node reproduce_issue.js
__STEP_CMD__

run 8 <<'__STEP_CMD__'
cat src/transformers/TypeScriptTransformer.ts
__STEP_CMD__

run 9 <<'__STEP_CMD__'
cat src/transformers/FlowTransformer.ts
__STEP_CMD__

run 10 <<'__STEP_CMD__'
cat src/transformers/RootTransformer.ts | head -200
__STEP_CMD__

run 11 <<'__STEP_CMD__'
grep -n "processPossibleTypeRange" src/transformers/RootTransformer.ts
__STEP_CMD__

run 12 <<'__STEP_CMD__'
sed -n '435,500p' src/transformers/RootTransformer.ts
__STEP_CMD__

run 13 <<'__STEP_CMD__'
grep -n "processClass" src/transformers/RootTransformer.ts | head -20
__STEP_CMD__

run 14 <<'__STEP_CMD__'
sed -n '221,350p' src/transformers/RootTransformer.ts
__STEP_CMD__

run 15 <<'__STEP_CMD__'
cat src/util/getClassInfo.ts | head -100
__STEP_CMD__

run 16 <<'__STEP_CMD__'
grep -n "processConstructor" src/util/getClassInfo.ts
__STEP_CMD__

run 17 <<'__STEP_CMD__'
sed -n '246,350p' src/util/getClassInfo.ts
__STEP_CMD__

run 18 <<'__STEP_CMD__'
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
__STEP_CMD__

run 19 <<'__STEP_CMD__'
node test_tokens.js 2>&1 | head -50
__STEP_CMD__

run 20 <<'__STEP_CMD__'
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
__STEP_CMD__

run 21 <<'__STEP_CMD__'
node test_tokens2.js 2>&1
__STEP_CMD__

run 22 <<'__STEP_CMD__'
ls -la src/parser/
__STEP_CMD__

run 23 <<'__STEP_CMD__'
find test -name "*.js" -o -name "*.ts" | grep -i constructor | head -5
__STEP_CMD__

run 24 <<'__STEP_CMD__'
find test -type f | head -20
__STEP_CMD__

run 25 <<'__STEP_CMD__'
grep -n "constructor" test/typescript-test.ts | head -20
__STEP_CMD__

run 26 <<'__STEP_CMD__'
grep -n "constructor.*:" test/typescript-test.ts | head -20
__STEP_CMD__

run 27 <<'__STEP_CMD__'
sed -n '193,220p' src/transformers/RootTransformer.ts
__STEP_CMD__

run 28 <<'__STEP_CMD__'
find src/parser -name "*.ts" -exec grep -l "returnType" {} \;
__STEP_CMD__

run 29 <<'__STEP_CMD__'
find src/parser -name "*.ts" | head -20
__STEP_CMD__

run 30 <<'__STEP_CMD__'
grep -n "constructor" src/parser/plugins/typescript.ts | head -20
__STEP_CMD__

run 31 <<'__STEP_CMD__'
sed -n '315,340p' src/parser/plugins/typescript.ts
__STEP_CMD__

run 32 <<'__STEP_CMD__'
grep -n "colon" src/parser/plugins/typescript.ts | head -20
__STEP_CMD__

run 33 <<'__STEP_CMD__'
grep -n "tsFillSignature" src/parser/plugins/typescript.ts
__STEP_CMD__

run 34 <<'__STEP_CMD__'
sed -n '243,260p' src/parser/plugins/typescript.ts
__STEP_CMD__

run 35 <<'__STEP_CMD__'
grep -n "tsParseTypeOrTypePredicateAnnotation" src/parser/plugins/typescript.ts
__STEP_CMD__

run 36 <<'__STEP_CMD__'
sed -n '674,700p' src/parser/plugins/typescript.ts
__STEP_CMD__

run 37 <<'__STEP_CMD__'
grep -n "pushTypeContext" src/parser/plugins/types.ts
__STEP_CMD__

run 38 <<'__STEP_CMD__'
grep -rn "pushTypeContext" src/parser/
__STEP_CMD__

run 39 <<'__STEP_CMD__'
sed -n '192,210p' src/parser/tokenizer/index.ts
__STEP_CMD__

run 40 <<'__STEP_CMD__'
grep -n "^function expect" src/parser/traverser/util.ts
__STEP_CMD__

run 41 <<'__STEP_CMD__'
grep -n "export function expect" src/parser/traverser/util.ts
__STEP_CMD__

run 42 <<'__STEP_CMD__'
sed -n '83,95p' src/parser/traverser/util.ts
__STEP_CMD__

run 43 <<'__STEP_CMD__'
grep -n "^export function next" src/parser/tokenizer/index.ts
__STEP_CMD__

run 44 <<'__STEP_CMD__'
sed -n '171,190p' src/parser/tokenizer/index.ts
__STEP_CMD__

run 45 <<'__STEP_CMD__'
grep -n "class Token" src/parser/tokenizer/index.ts
__STEP_CMD__

run 46 <<'__STEP_CMD__'
sed -n '111,165p' src/parser/tokenizer/index.ts
__STEP_CMD__

run 47 <<'__STEP_CMD__'
grep -n "parseClassMethod" src/parser/traverser/statement.ts
__STEP_CMD__

run 48 <<'__STEP_CMD__'
sed -n '881,950p' src/parser/traverser/statement.ts
__STEP_CMD__

run 49 <<'__STEP_CMD__'
grep -n "^function parseMethod" src/parser/traverser/expression.ts
__STEP_CMD__

run 50 <<'__STEP_CMD__'
grep -n "export function parseMethod" src/parser/traverser/expression.ts
__STEP_CMD__

run 51 <<'__STEP_CMD__'
sed -n '918,970p' src/parser/traverser/expression.ts
__STEP_CMD__

run 52 <<'__STEP_CMD__'
grep -n "tsParseFunctionBodyAndFinish" src/parser/plugins/typescript.ts
__STEP_CMD__

run 53 <<'__STEP_CMD__'
sed -n '1202,1230p' src/parser/plugins/typescript.ts
__STEP_CMD__

run 54 <<'__STEP_CMD__'
grep -n "flowParseFunctionBodyAndFinish" src/parser/plugins/flow.ts
__STEP_CMD__

run 55 <<'__STEP_CMD__'
sed -n '716,750p' src/parser/plugins/flow.ts
__STEP_CMD__

run 56 <<'__STEP_CMD__'
grep -n "flowParseTypeAndPredicateInitialiser" src/parser/plugins/flow.ts
__STEP_CMD__

run 57 <<'__STEP_CMD__'
sed -n '73,90p' src/parser/plugins/flow.ts
__STEP_CMD__

run 58 <<'__STEP_CMD__'
sed -n '830,850p' src/parser/traverser/statement.ts
__STEP_CMD__

run 59 <<'__STEP_CMD__'
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
__STEP_CMD__

run 60 <<'__STEP_CMD__'
node debug_tokens.js
__STEP_CMD__

run 61 <<'__STEP_CMD__'
grep -n "isConstructor" src/parser/plugins/typescript.ts
__STEP_CMD__

run 62 <<'__STEP_CMD__'
grep -n "isConstructor" src/parser/plugins/flow.ts
__STEP_CMD__

run 63 <<'__STEP_CMD__'
grep -n "export function parseFunctionParams" src/parser/traverser/expression.ts
__STEP_CMD__

run 64 <<'__STEP_CMD__'
grep -n "parseFunctionParams" src/parser/traverser/expression.ts | head -5
__STEP_CMD__

run 65 <<'__STEP_CMD__'
grep -n "^export function parseFunctionParams" src/parser/traverser/lval.ts
__STEP_CMD__

run 66 <<'__STEP_CMD__'
grep -n "function parseFunctionParams" src/parser/traverser/lval.ts
__STEP_CMD__

run 67 <<'__STEP_CMD__'
grep -rn "function parseFunctionParams" src/parser/
__STEP_CMD__

run 68 <<'__STEP_CMD__'
sed -n '689,750p' src/parser/traverser/statement.ts
__STEP_CMD__

run 69 <<'__STEP_CMD__'
grep -B5 -A10 "ContextualKeyword._constructor" src/parser/traverser/statement.ts | head -40
__STEP_CMD__

run 70 <<'__STEP_CMD__'
grep -rn "constructor.*:.*{" test/ | grep -E "(typescript|flow)" | head -10
__STEP_CMD__

run 71 <<'__STEP_CMD__'
grep -n "tsStartParseFunctionParams" src/parser/plugins/typescript.ts
__STEP_CMD__

run 72 <<'__STEP_CMD__'
sed -n '1521,1540p' src/parser/plugins/typescript.ts
__STEP_CMD__

run 73 <<'__STEP_CMD__'
grep -i "constructor" src/parser/plugins/typescript.ts
__STEP_CMD__

run 74 <<'__STEP_CMD__'
sed -n '435,445p' src/transformers/RootTransformer.ts
__STEP_CMD__

run 75 <<'__STEP_CMD__'
grep -n "function isClassMethod" src/parser/traverser/statement.ts
__STEP_CMD__

run 76 <<'__STEP_CMD__'
sed -n '754,780p' src/parser/traverser/statement.ts
__STEP_CMD__

run 77 <<'__STEP_CMD__'
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
__STEP_CMD__

run 78 <<'__STEP_CMD__'
node test_method_return.js
__STEP_CMD__

run 79 <<'__STEP_CMD__'
grep -rn "constructor" src/transformers/ | grep -v "// " | head -20
__STEP_CMD__

run 80 <<'__STEP_CMD__'
sed -n '246,305p' src/util/getClassInfo.ts
__STEP_CMD__

run 81 <<'__STEP_CMD__'
sed -n '221,248p' src/transformers/RootTransformer.ts
__STEP_CMD__

run 82 <<'__STEP_CMD__'
grep -n "restoreFromSnapshot" src/util/getClassInfo.ts
__STEP_CMD__

run 83 <<'__STEP_CMD__'
tail -20 src/util/getClassInfo.ts
__STEP_CMD__

run 84 <<'__STEP_CMD__'
sed -n '180,245p' src/util/getClassInfo.ts
__STEP_CMD__

run 85 <<'__STEP_CMD__'
grep -n "rangesToRemove.push" src/util/getClassInfo.ts
__STEP_CMD__

run 86 <<'__STEP_CMD__'
sed -n '150,165p' src/util/getClassInfo.ts
__STEP_CMD__

run 87 <<'__STEP_CMD__'
sed -n '278,285p' src/util/getClassInfo.ts
__STEP_CMD__

run 88 <<'__STEP_CMD__'
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
__STEP_CMD__

run 89 <<'__STEP_CMD__'
patch -p1 < fix.patch
__STEP_CMD__

run 90 <<'__STEP_CMD__'
npm run build 2>&1 | tail -20
__STEP_CMD__

run 91 <<'__STEP_CMD__'
npx tsc 2>&1 | head -30
__STEP_CMD__

run 92 <<'__STEP_CMD__'
node reproduce_issue.js
__STEP_CMD__

run 93 <<'__STEP_CMD__'
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
__STEP_CMD__

run 94 <<'__STEP_CMD__'
node test_isType.js 2>&1 | grep -A2 -B2 "constructor"
__STEP_CMD__

run 95 <<'__STEP_CMD__'
node test_isType.js 2>&1
__STEP_CMD__

run 96 <<'__STEP_CMD__'
cat > test.ts << 'EOF'
class Foo {
  constructor(): Foo {
    return this;
  }
}
EOF
__STEP_CMD__

run 97 <<'__STEP_CMD__'
npx tsc --noEmit test.ts 2>&1
__STEP_CMD__

run 98 <<'__STEP_CMD__'
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
__STEP_CMD__

run 99 <<'__STEP_CMD__'
node test_parse2.js
__STEP_CMD__

run 100 <<'__STEP_CMD__'
cat reproduce_issue.js
__STEP_CMD__

run 101 <<'__STEP_CMD__'
grep -A30 "export function transform" src/index.ts | head -40
__STEP_CMD__

run 102 <<'__STEP_CMD__'
grep -A50 "function getSucraseContext" src/index.ts | head -60
__STEP_CMD__

run 103 <<'__STEP_CMD__'
cat src/parser/index.ts
__STEP_CMD__

run 104 <<'__STEP_CMD__'
node reproduce_issue.js 2>&1
__STEP_CMD__

run 105 <<'__STEP_CMD__'
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
__STEP_CMD__

run 106 <<'__STEP_CMD__'
node debug_transform.js
__STEP_CMD__

run 107 <<'__STEP_CMD__'
grep -A5 "Skip any return type" dist/util/getClassInfo.js
__STEP_CMD__

run 108 <<'__STEP_CMD__'
npx tsc --project tsconfig.json 2>&1 | grep -i error | head -10
__STEP_CMD__

run 109 <<'__STEP_CMD__'
grep -A5 "Skip any return type" dist/util/getClassInfo.js
__STEP_CMD__

run 110 <<'__STEP_CMD__'
ls -la dist/util/getClassInfo.js
__STEP_CMD__

run 111 <<'__STEP_CMD__'
cat tsconfig.json
__STEP_CMD__

run 112 <<'__STEP_CMD__'
cat package.json | grep -A10 '"scripts"'
__STEP_CMD__

run 113 <<'__STEP_CMD__'
./node_modules/.bin/sucrase-node script/build.ts --fast 2>&1 | tail -30
__STEP_CMD__

run 114 <<'__STEP_CMD__'
grep -A5 "Skip any return type" dist/util/getClassInfo.js
__STEP_CMD__

run 115 <<'__STEP_CMD__'
node reproduce_issue.js
__STEP_CMD__

run 116 <<'__STEP_CMD__'
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
__STEP_CMD__

run 117 <<'__STEP_CMD__'
node test_edge_cases.js
__STEP_CMD__

run 118 <<'__STEP_CMD__'
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
__STEP_CMD__

run 119 <<'__STEP_CMD__'
node test_flow.js
__STEP_CMD__

run 120 <<'__STEP_CMD__'
npm test 2>&1 | tail -50
__STEP_CMD__

run 121 <<'__STEP_CMD__'
./node_modules/.bin/mocha --require sucrase-register test/*-test.ts 2>&1 | tail -100
__STEP_CMD__

run 122 <<'__STEP_CMD__'
cat .mocharc.js
__STEP_CMD__

run 123 <<'__STEP_CMD__'
./node_modules/.bin/mocha --require ./register/index.js test/*-test.ts 2>&1 | tail -100
__STEP_CMD__

run 124 <<'__STEP_CMD__'
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
__STEP_CMD__

run 125 <<'__STEP_CMD__'
node test_constructor_return_type.js
__STEP_CMD__

run 126 <<'__STEP_CMD__'
cat src/util/getClassInfo.ts | grep -A10 -B5 "Skip any return type"
__STEP_CMD__

run 127 <<'__STEP_CMD__'
grep -n "tokens.nextToken()" src/util/getClassInfo.ts | head -20
__STEP_CMD__

run 128 <<'__STEP_CMD__'
grep -n "function process" src/util/getClassInfo.ts
__STEP_CMD__

run 129 <<'__STEP_CMD__'
git diff src/util/getClassInfo.ts
__STEP_CMD__

run 130 <<'__STEP_CMD__'
git diff src/util/getClassInfo.ts > patch.txt
__STEP_CMD__

run 131 <<'__STEP_CMD__'
cat patch.txt
__STEP_CMD__

run 132 <<'__STEP_CMD__'
node reproduce_issue.js
__STEP_CMD__
