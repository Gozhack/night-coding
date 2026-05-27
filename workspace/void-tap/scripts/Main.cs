using Godot;
using System;

namespace VoidTap;

public partial class Main : Node2D
{
	private Label _gameOverLabel;

	public override void _Ready()
	{
		_gameOverLabel = GetNode<Label>("UI/GameOverLabel");
		
		// Conectar a la señal de GameManager
		GameManager.Instance.PlayerDied += OnGameOver;
	}

	private void OnGameOver()
	{
		if (_gameOverLabel != null)
		{
			_gameOverLabel.Visible = true;
		}
	}
}
