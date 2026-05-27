using Godot;
using System;

namespace GridRunner;

public partial class GameManager : Node
{
	public static GameManager Instance { get; private set; }
	
	[Signal]
	public delegate void PlayerDiedEventHandler();

	public bool IsPlaying = true;

	public override void _Ready()
	{
		Instance = this;
	}

	public void GameOver()
	{
		if (!IsPlaying) return;
		IsPlaying = false;
		
		EmitSignal(SignalName.PlayerDied);
		GD.Print("Grid Runner: Game Over!");
		
		GetTree().Paused = true;
		Timer timer = new Timer();
		AddChild(timer);
		timer.WaitTime = 2.0f;
		timer.OneShot = true;
		timer.ProcessMode = ProcessModeEnum.Always;
		timer.Timeout += () => {
			GetTree().Paused = false;
			GetTree().ReloadCurrentScene();
			IsPlaying = true;
		};
		timer.Start();
	}
}
