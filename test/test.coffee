protagonist = require '../build/Release/protagonist'
{assert} = require 'chai'

describe "API Blueprint parser", ->
  it 'parses API name', ->
    protagonist.parse '# My API', (err, result) ->

      assert.isNull err
      assert.isDefined result
      assert.strictEqual result.ast.name, 'My API'

  it 'parses API description', ->
    source = """
**description**

"""
    protagonist.parse source, (err, result) ->
      
      assert.isNull err

      assert.isDefined result
      assert.strictEqual result.ast.name, ''
      assert.isDefined result.ast.description
      assert.strictEqual result.ast.description, '**description**\n'

  it 'parses resource group', ->
    source = """
---

# Group Name
_description_

"""
    protagonist.parse source, (err, result) ->

      assert.isNull err

      assert.isDefined result.ast.resourceGroups
      assert.strictEqual result.ast.resourceGroups.length, 1
      assert.isDefined result.ast.resourceGroups[0] 

      resourceGroup = result.ast.resourceGroups[0]
      assert.isDefined resourceGroup.name
      assert.strictEqual resourceGroup.name, 'Name'
      assert.isDefined resourceGroup.description
      assert.strictEqual resourceGroup.description, '_description_\n'

  it 'parses resource', ->
    source = """
# My Resource [/resource]
Resource description

+ Headers

        X-Resource-Header: Metaverse

+ Resource Object (text/plain)
  
        Hello World

## Retrieve Resource [GET]
Method description

+ Headers

        X-Method-Header: Pizza delivery

+ Response 200 (text/plain)
  
  Response description

  + Headers

            X-Response-Header: Fighter

  + Body

            Y.T.

  + Schema

            Kourier

## Delete Resource [DELETE]

+ Response 200

    [Resource][]

"""

    protagonist.parse source, (err, result) ->
      assert.isNull err

      assert.strictEqual result.ast.resourceGroups.length, 1

      resourceGroup = result.ast.resourceGroups[0]
      assert.strictEqual resourceGroup.name, ''
      assert.strictEqual resourceGroup.description, ''
      
      assert.isDefined resourceGroup.resources
      assert.strictEqual resourceGroup.resources.length, 1
      assert.isDefined resourceGroup.resources[0]

      resource = resourceGroup.resources[0]
      assert.isDefined resource.uriTemplate
      assert.strictEqual resource.uriTemplate, '/resource'
      assert.isDefined resource.name
      assert.strictEqual resource.name, 'My Resource'
      assert.isDefined resource.description
      assert.strictEqual resource.description, 'Resource description\n\n'
      assert.isDefined resource.headers

      assert.strictEqual Object.keys(resource.headers).length, 1
      assert.isDefined resource.headers['X-Resource-Header']
      assert.isDefined resource.headers['X-Resource-Header'].value
      assert.strictEqual resource.headers['X-Resource-Header'].value, 'Metaverse'

      assert.isDefined resource.model
      assert.strictEqual resource.model.name, 'Resource'
      assert.isDefined resource.model.description
      assert.strictEqual resource.model.description.length, 0
      assert.isDefined resource.model.body
      assert.strictEqual resource.model.body, 'Hello World\n'
      assert.isDefined resource.model.headers
      assert.strictEqual Object.keys(resource.model.headers).length, 1
      assert.isDefined resource.model.headers['Content-Type']
      assert.isDefined resource.model.headers['Content-Type'].value
      assert.strictEqual resource.model.headers['Content-Type'].value, 'text/plain'

      assert.isDefined resource.actions
      assert.strictEqual resource.actions.length, 2
      assert.isDefined resource.actions[0]

      action = resource.actions[0]
      assert.isDefined action.method
      assert.strictEqual action.method, 'GET'
      assert.isDefined action.name
      assert.strictEqual action.name, 'Retrieve Resource'
      assert.isDefined action.description
      assert.strictEqual action.description, 'Method description\n\n'
      assert.isDefined action.headers
      assert.strictEqual Object.keys(action.headers).length, 1
      assert.isDefined action.headers['X-Method-Header']
      assert.isDefined action.headers['X-Method-Header'].value
      assert.strictEqual action.headers['X-Method-Header'].value, 'Pizza delivery'

      assert.isDefined action.transactions
      assert.strictEqual action.transactions.length, 1
      assert.isDefined action.transactions[0]

      transaction = action.transactions[0]
      assert.isDefined transaction.requests
      assert.strictEqual transaction.requests.length, 0
      assert.isDefined transaction.responses
      assert.strictEqual transaction.responses.length, 1
      assert.isDefined transaction.responses[0]

      response = transaction.responses[0]
      assert.isDefined response.name
      assert.strictEqual response.name, '200'
      assert.isDefined response.description
      assert.strictEqual response.description, 'Response description\n'

      assert.isDefined response.headers
      assert.strictEqual Object.keys(response.headers).length, 2

      assert.isDefined response.headers['Content-Type']
      assert.isDefined response.headers['Content-Type'].value
      assert.strictEqual response.headers['Content-Type'].value, 'text/plain'
      assert.isDefined response.headers['X-Response-Header']
      assert.isDefined response.headers['X-Response-Header'].value
      assert.strictEqual response.headers['X-Response-Header'].value, 'Fighter'

      assert.isDefined response.body
      assert.strictEqual response.body, 'Y.T.\n'
      assert.isDefined response.schema
      assert.strictEqual response.schema, 'Kourier\n'

      action = resource.actions[1]
      assert.isDefined action.method
      assert.strictEqual action.method, 'DELETE'

      assert.isDefined action.transactions
      assert.strictEqual action.transactions.length, 1
      assert.isDefined action.transactions[0]

      transaction = action.transactions[0]
      assert.isDefined transaction.responses[0]
      response = transaction.responses[0]
      assert.isDefined response.name
      assert.strictEqual response.name, '200'
      assert.isDefined response.description
      assert.strictEqual response.description.length, 0
      assert.isDefined response.body
      assert.strictEqual response.body, 'Hello World\n'
      assert.isDefined response.headers

      assert.strictEqual Object.keys(response.headers).length, 1
      assert.isDefined response.headers['Content-Type']
      assert.isDefined response.headers['Content-Type'].value
      assert.strictEqual response.headers['Content-Type'].value, 'text/plain'

  it 'fails to parse blueprint with tabs', ->
    source = """
# /resource
# GET
+ Response 
\tC
"""
    protagonist.parse source, (err, result) ->

      assert.isDefined err
      assert.isNotNull err
      assert err.message.length != 0
      assert err.code != 0
      assert.isDefined err.location

  it 'parses blueprint with warnings', ->
    source = """
API description

---

Group description

"""
    protagonist.parse source, (err, result) ->

      assert.isNull err

      assert.isDefined result.warnings
      assert.strictEqual result.warnings.length, 1

      assert.isDefined result.warnings[0].message
      assert.isDefined result.warnings[0].code
      assert.isDefined result.warnings[0].location

      assert.isDefined result.ast

  it 'parses blueprint metadata', ->
    source = """
A: 1
B: 2
C: 3

# API Name
"""
    protagonist.parse source, (err, result) ->

      assert.isNull err

      assert.isDefined result.warnings
      assert.strictEqual result.warnings.length, 0
      
      assert.isDefined result.ast.metadata
      assert.strictEqual Object.keys(result.ast.metadata).length, 3

      metadata = result.ast.metadata

      assert.isDefined metadata.A
      assert.isDefined metadata.A.value
      assert.strictEqual metadata.A.value, '1'

      assert.isDefined metadata.B
      assert.isDefined metadata.B.value
      assert.strictEqual metadata.B.value, '2'

      assert.isDefined metadata.C
      assert.isDefined metadata.C.value
      assert.strictEqual metadata.C.value, '3'

  it 'accepts options', ->
    source = """
**description**

"""
    options =
      requireBlueprintName: true

    protagonist.parse source, options, (err, result) ->

      assert.isDefined err
      assert.isNotNull err
      assert err.message.length != 0
      assert err.code != 0
      assert.isDefined err.location
