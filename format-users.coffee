#!/usr/bin/env coffee
fs = require 'fs'

# Reducer.
minimum = (min, current) ->
  if current < min
    current
  else
    min

top = (stats, field, type) ->
  get = (stat) ->
    value = stat[field]
    if type is 'list' then value.length else value

  format = (stat) ->
    value = get stat
    switch type
      when 'thousands' then "#{(value / 1000)}k"
      else value

  stats
    .slice()
    .sort (a, b) ->
      get(b) - get(a)
    .slice(0, 15)
    .map (stat) ->
      login = stat.login
      "[#{login}](https://github.com/#{login}) (#{format stat})"
    .join ', '

stats2markdown = (datafile, mdfile, title) ->
  stats = require(datafile)
  minFollowers = stats.map((_) -> _.followers).reduce(minimum, 1000)
  maxNumber = 1000

  today = new Date()
  from = new Date()
  from.setYear today.getFullYear() - 1

  out = """
  # Most active GitHub users in India

  <table cellspacing="0"><thead>
  <th scope="col">#</th>
  <th scope="col">User</th>
  <th scope="col">Organisations</th>
  <th scope="col">Email</th>
  <th scope="col">Contribs</th>
  <th scope="col">Location</th>
  <th scope="col" width="30">Picture</th>
  </thead><tbody>\n
  """

  rows = stats
  .filter((stat) -> stat.contributions < 20000).slice(0, maxNumber).map (stat, index) ->
    """
    <tr>
      <th scope="row">##{index + 1}</th>
      <td><a href="https://github.com/#{stat.login}">#{stat.login}</a>#{if stat.name then ' (' + stat.name + ')' else ''}</td>
      <td>#{stat.organizations}</td>
      <td>#{stat.email}</td>
      <td>#{stat.contributions}</td>
      <!-- <td>#{stat.language}</td> -->
      <td>#{stat.location}</td>
      <td><img width="30" height="30" src="#{stat.gravatar.replace('?s=400', '?s=30')}"></td>
    </tr>
    """.replace(/\n/g, '')

  out += "#{rows.join('\n')}\n</tbody></table>\n\n"

  fs.writeFileSync mdfile, out
  console.log 'Saved to', mdfile

stats2markdown './raw/github-users-stats.json', './formatted/top_github_india_users.html'
