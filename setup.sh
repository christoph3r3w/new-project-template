#!/bin/bash

# Colors for nice output
GREEN='\033[0;32m'
BLUE='\033[1;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'

echo -e "${BLUE}${BOLD}🛠 Starting project setup...${RESET}"

# --- Step 1: Get project/client name ---
read -p "Enter the project/client name: " client_name

# --- Step 2: Get project description ---
read -p "Enter a short project description: " project_description

# Escape any special characters (e.g., slashes, ampersands) in the description
escaped_description=$(echo "$project_description" | sed 's/[&/\]/\\&/g')

# --- Step 3: Dev port ---
read -p "Preferred dev server port (default 5173): " dev_port
dev_port=${dev_port:-5173}

# --- Step 4: PWA choice ---
read -p "Should this project be a Progressive Web App? (y/n): " is_pwa

# --- Step 5: Optional MCP setup ---
echo -e "\n${CYAN}🌐 Optional: Setup Figma MCP (Model Context Protocol)${RESET}"
read -p "Enter MCP API URL (or leave blank to skip): " mcp_url

# --- Step 6: Update README.md ---
if [ -f README.md ]; then
  sed -i.bak "s/PROJECT_NAME/$client_name/g" README.md
  sed -i.bak "s/PROJECT_DESCRIPTION/$escaped_description/g" README.md
  rm README.md.bak
fi

# --- Step 7: Update src/app.html ---
if [ -f src/app.html ]; then
  sed -i.bak -E "s|<title>.*</title>|<title>$client_name</title>|" src/app.html

  if grep -q 'name="description"' src/app.html; then
    sed -i.bak -E "s|<meta name=\"description\" content=\".*\">|<meta name=\"description\" content=\"$escaped_description\">|" src/app.html
  else
    sed -i.bak -E "/<\/head>/i \ \ <meta name=\"description\" content=\"$escaped_description\">" src/app.html
  fi

  if [[ "$is_pwa" =~ ^[Yy]$ ]]; then
    if ! grep -q 'rel="manifest"' src/app.html; then
      sed -i.bak '/<\/head>/i \ \ <link rel="manifest" href="/manifest.json">' src/app.html
    fi
  fi

  rm src/app.html.bak
fi

# --- Step 8: Create manifest.json for PWA ---
if [[ "$is_pwa" =~ ^[Yy]$ ]]; then
  mkdir -p public
  cat <<EOF > public/manifest.json
{
  "name": "$client_name",
  "short_name": "$client_name",
  "start_url": "/",
  "display": "standalone",
  "background_color": "#ffffff",
  "theme_color": "#000000",
  "description": "$project_description",
  "icons": [
    {
      "src": "/icon-192.png",
      "sizes": "192x192",
      "type": "image/png"
    },
    {
      "src": "/icon-512.png",
      "sizes": "512x512",
      "type": "image/png"
    }
  ]
}
EOF
  echo -e "${GREEN}✅ Created public/manifest.json${RESET}"
fi

# --- Step 9: Create .env file ---
if [ -f .env.example ]; then
  cp .env.example .env
  echo "VITE_PORT=$dev_port" >> .env
  if [ ! -z "$mcp_url" ]; then
    echo "MCP_API_URL=$mcp_url" >> .env
  fi
  echo -e "${GREEN}✅ .env created${RESET}"
fi

# --- Step 10: Install dependencies ---
if [ -f package.json ]; then
  echo -e "${BLUE}📦 Installing npm packages...${RESET}"
  npm install
fi

# --- Step 11: Init new git repo ---
echo -e "${BLUE}🔃 Initializing git repository...${RESET}"
rm -rf .git
git init
git add .
git commit -m "Initial commit for $client_name"

# --- Final Output ---
echo ""
echo -e "${GREEN}${BOLD}✅ Setup complete for '$client_name'!${RESET}\n"

echo -e "${BOLD}➡ Next steps:${RESET}"
echo -e "1. 🔍 Review the ${CYAN}src/${RESET} and ${CYAN}components/${RESET} folders for accuracy"
echo -e "2. 📝 Confirm ${CYAN}<title>${RESET} and ${CYAN}<meta>${RESET} tags in ${CYAN}src/app.html${RESET}"
if [[ "$is_pwa" =~ ^[Yy]$ ]]; then
  echo -e "3. 🧱 PWA manifest configured – test it in browser dev tools"
fi
if [ ! -z "$mcp_url" ]; then
  echo -e "4. 🔌 MCP API set to ${YELLOW}$mcp_url${RESET} (check .env)"
fi
echo -e "5. 🛠 If anything's missing, update ${YELLOW}UpdateTheSetup.md${RESET} to improve the template"
echo ""
echo -e "${BOLD}🚀 Run your dev server:${RESET} ${CYAN}npm run dev -- --port $dev_port${RESET}"
echo -e "${BOLD}🎉 Happy shipping!${RESET}"
