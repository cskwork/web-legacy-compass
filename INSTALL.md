# Install web-legacy-compass

<details>
<summary><strong>Claude Code</strong></summary>

### Install

```bash
claude plugin marketplace add cskwork/web-legacy-compass
claude plugin install web-legacy-compass@web-legacy-compass
```

Type `/web-legacy-compass`.

### Verify

```bash
claude plugin list
```

### Update

```bash
claude plugin marketplace update web-legacy-compass
```

### Uninstall

```bash
claude plugin uninstall web-legacy-compass
claude plugin marketplace remove web-legacy-compass
```

</details>

<details>
<summary><strong>Codex</strong></summary>

### Install

```bash
codex plugin marketplace add cskwork/web-legacy-compass --ref main
codex plugin add web-legacy-compass@web-legacy-compass
```

Type `$web-legacy-compass`.

### Verify

```bash
codex plugin list
```

### Uninstall

```bash
codex plugin remove web-legacy-compass
codex plugin marketplace remove web-legacy-compass
```

</details>

<details>
<summary><strong>Gemini CLI</strong></summary>

### Install (extension, always-on)

```bash
gemini extensions install https://github.com/cskwork/web-legacy-compass
```

### Install (command, opt-in)

```bash
mkdir -p ~/.gemini/commands
curl -fsSL https://raw.githubusercontent.com/cskwork/web-legacy-compass/main/skills/web-legacy-compass/agents/gemini.toml \
  -o ~/.gemini/commands/web-legacy-compass.toml
```

Type `/web-legacy-compass` in a new session.

### Verify

```bash
gemini extensions list
```

### Uninstall

```bash
gemini extensions uninstall web-legacy-compass
```

</details>

<details>
<summary><strong>Cursor, OpenCode, Amp, and other agent-skills harnesses</strong></summary>

### Install

```bash
npx skills add cskwork/web-legacy-compass
npx skills add cskwork/web-legacy-compass -g
```

Type `/web-legacy-compass` in a new agent chat.

### Verify

```bash
npx skills list
```

### Update

```bash
npx skills update web-legacy-compass
```

### Uninstall

```bash
npx skills remove web-legacy-compass
```

</details>

<details>
<summary><strong>Antigravity (agy)</strong></summary>

### Install

```bash
agy plugin install https://github.com/cskwork/web-legacy-compass
```

### Verify

```bash
agy plugin list
```

### Uninstall

```bash
agy plugin uninstall web-legacy-compass
```

</details>
