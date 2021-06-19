from rest_framework import serializers

from login.models import User


class RegistrationSerializer(serializers.ModelSerializer):

	class Meta:
		model = User
		fields = ['username']

	def save(self):
		username = str(self.validated_data['username'])
		account = User(username=username)
		account.save()
		return account