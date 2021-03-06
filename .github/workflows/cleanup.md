name: Clean Up

on:
  schedule:
    - cron:  '15,45 * * * *'

jobs:
  registry-prune:
    runs-on: ubuntu-latest
    steps:
      - name: Fetch releases
        run: |
          GH_REPO=(${GITHUB_REPOSITORY//\// });
          curl -X POST \
            -s \
            -H "Accept: application/vnd.github.package-deletes-preview+json" \
            -H "Authorization: bearer ${{ secrets.GITHUB_TOKEN }}" \
            -d "{\"query\":\"query {repository(owner:\\\"${GH_REPO[0]}\\\", name:\\\"${GH_REPO[1]}\\\") {registryPackages(last:1) {edges{node{id, name, versions(last:100){edges {node {id, updatedAt, version}}}}}}}}\"}" \
            -o /tmp/response.json \
            --url https://api.github.com/graphql;
            cat /tmp/response.json
      - name: Filter Releases
        run: "cat /tmp/response.json | jq -r 'def daysAgo(days): (now | floor) - (days * 86400); [.data.repository.registryPackages.edges[0].node.versions.edges | sort_by(.node.updatedAt|fromdate) | reverse | .[] | select( .node.version != \"docker-base-layer\" ) | .node.id] | unique_by(.) | @csv'  | cut -d, -f1  | sed -e 's/^\"//' -e 's/\"$//' > /tmp/release.json"
      - name: Show Release
        id: release
        run: printf "::set-output name=id::%s" $(cat /tmp/release.json)
      - name: Delete Release
        uses: WyriHaximus/github-action-delete-package@master
        if: steps.release.outputs.id != ''
        with:
          packageVersionId: ${{ steps.release.outputs.id }}
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
