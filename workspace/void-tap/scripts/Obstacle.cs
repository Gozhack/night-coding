using Godot;
using System;

namespace VoidTap;

public partial class Obstacle : Area2D
{
	[Export]
	public float MinSpeed = 200.0f;
	[Export]
	public float MaxSpeed = 500.0f;

	private float _speed;

	public override void _Ready()
	{
		// Velocidad aleatoria
		_speed = (float)GD.RandRange(MinSpeed, MaxSpeed);
		
		// Conectar señal de colisión
		BodyEntered += OnBodyEntered;
	}

	public override void _PhysicsProcess(double delta)
	{
		// Caer hacia abajo
		Position += new Vector2(0, _speed * (float)delta);

		// Eliminar si sale de la pantalla (asumiendo 648px de alto + margen)
		if (Position.Y > 750)
		{
			QueueFree();
		}
	}

	private void OnBodyEntered(Node2D body)
	{
		if (body is Player)
		{
			// Notificar al Singleton o al Main del Game Over
			GameManager.Instance.GameOver();
		}
	}
}
