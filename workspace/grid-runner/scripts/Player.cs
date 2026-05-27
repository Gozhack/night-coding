using Godot;
using System;

namespace GridRunner;

public partial class Player : CharacterBody2D
{
	[Export]
	public int GridSize = 64;
	
	private Vector2 _targetPosition;
	private bool _isMoving = false;

	public override void _Ready()
	{
		_targetPosition = Position;
		// Asegurar que el player esté alineado a la grid
		Position = new Vector2(
			Mathf.Floor(Position.X / GridSize) * GridSize + GridSize / 2,
			Mathf.Floor(Position.Y / GridSize) * GridSize + GridSize / 2
		);
		_targetPosition = Position;
	}

	public override void _Input(InputEvent @event)
	{
		if (_isMoving) return;

		Vector2 direction = Vector2.Zero;

		if (@event.IsActionPressed("ui_up")) direction = Vector2.Up;
		else if (@event.IsActionPressed("ui_down")) direction = Vector2.Down;
		else if (@event.IsActionPressed("ui_left")) direction = Vector2.Left;
		else if (@event.IsActionPressed("ui_right")) direction = Vector2.Right;

		if (direction != Vector2.Zero)
		{
			_targetPosition = Position + direction * GridSize;
			_isMoving = true;
		}
	}

	public override void _PhysicsProcess(double delta)
	{
		if (_isMoving)
		{
			float step = 400.0f * (float)delta;
			if (Position.DistanceTo(_targetPosition) <= step)
			{
				Position = _targetPosition;
				_isMoving = false;
			}
			else
			{
				Position += ( _targetPosition - Position).Normalized() * step;
			}
		}
	}
}
