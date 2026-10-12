const sampleCustomersJson = '''
[
  {
    "id": "cust-001",
    "firstName": "John",
    "lastName": "Smith",
    "dateOfBirth": "1985-03-15",
    "maritalStatus": "Married",
    "secureId": "123-45-6789",
    "addresses": [
      {"id": "addr-001", "type": "Home", "street": "123 Oak Street", "city": "San Francisco", "state": "CA", "zipCode": "94102"}
    ],
    "phones": [
      {"id": "phone-001", "type": "Mobile", "number": "+1-415-555-0123", "isPrimary": false},
      {"id": "phone-002", "type": "Work", "number": "+1-415-555-0199", "isPrimary": true}
    ],
    "emails": [
      {"id": "email-001", "type": "Personal", "address": "john.smith@email.com", "isPrimary": true}
    ]
  },
  {
    "id": "cust-002",
    "firstName": "Sarah",
    "lastName": "Johnson",
    "dateOfBirth": "1990-07-22",
    "maritalStatus": "Single",
    "secureId": "987-65-4321",
    "addresses": [],
    "phones": [],
    "emails": []
  },
  {
    "id": "cust-003",
    "firstName": "Michael",
    "lastName": "Chen",
    "dateOfBirth": "1978-11-30",
    "maritalStatus": "Divorced",
    "secureId": "456-78-9012",
    "addresses": [],
    "phones": [],
    "emails": []
  }
]
''';
