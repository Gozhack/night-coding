using Godot;
using System;

namespace GridRunner;

public partial class Hazard : Area2D
{
	public override void _Ready()
	{
		BodyEntered += (body) => {
			if (body is Player)
			{
				GameManager.Instance.GameOver();
			}
		};
	}
}
