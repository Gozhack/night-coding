using Godot;
using System;

namespace VoidTap;

public partial class Spawner : Node2D
{
	[Export]
	public PackedScene ObstacleScene;
	[Export]
	public float SpawnRate = 1.0f;

	private Timer _spawnTimer;

	public override void _Ready()
	{
		_spawnTimer = new Timer();
		AddChild(_spawnTimer);
		_spawnTimer.WaitTime = SpawnRate;
		_spawnTimer.Timeout += OnSpawnTimerTimeout;
		_spawnTimer.Start();
	}

	private void OnSpawnTimerTimeout()
	{
		if (ObstacleScene == null || !GameManager.Instance.IsPlaying) return;

		Obstacle obstacle = ObstacleScene.Instantiate<Obstacle>();
		
		// Posición X aleatoria basada en el ancho estándar 1152
		float spawnX = (float)GD.RandRange(50, 1100);
		obstacle.Position = new Vector2(spawnX, -50);
		
		GetParent().AddChild(obstacle);
	}
}
