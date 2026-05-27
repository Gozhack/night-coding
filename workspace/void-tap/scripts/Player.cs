using Godot;
using System;

namespace VoidTap;

public partial class Player : CharacterBody2D
{
	[Export]
	public float Speed = 400.0f;

	private Vector2 _targetPosition;
	private bool _isMoving = false;

	public override void _Ready()
	{
		// Iniciar en el centro de la pantalla (aproximado)
		_targetPosition = Position;
	}

	public override void _Input(InputEvent @event)
	{
		if (@event is InputEventScreenTouch touch && touch.Pressed)
		{
			_targetPosition = touch.Position;
			_isMoving = true;
		}
		else if (@event is InputEventMouseButton mouse && mouse.Pressed && mouse.ButtonIndex == MouseButton.Left)
		{
			_targetPosition = mouse.Position;
			_isMoving = true;
		}
	}

	public override void _PhysicsProcess(double delta)
	{
		if (_isMoving)
		{
			Vector2 direction = (_targetPosition - GlobalPosition).Normalized();
			float distance = GlobalPosition.DistanceTo(_targetPosition);

			if (distance > 5.0f)
			{
				Velocity = direction * Speed;
				MoveAndSlide();
			}
			else
			{
				Velocity = Vector2.Zero;
				_isMoving = false;
			}
		}
	}
}
