using Godot;
using System;

namespace GridRunner;

public partial class Main : Node2D
{
	private Label _msg;

	public override void _Ready()
	{
		_msg = GetNode<Label>("UI/Msg");
		GameManager.Instance.PlayerDied += () => _msg.Visible = true;
	}
}
