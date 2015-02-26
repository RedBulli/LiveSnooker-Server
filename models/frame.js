module.exports = function(Sequelize, DataTypes) {
  var schema = {
    id: {
      primaryKey: true,
      type: DataTypes.UUID,
      defaultValue: DataTypes.UUIDV4
    }
  };
  var Frame = Sequelize.define("Frame", schema, {
      classMethods: {
        associate: function(models) {
          Frame.belongsTo(models.League, { foreignKey: {allowNull: false}, onDelete: "RESTRICT" });
          Frame.belongsTo(models.Player, { as: 'Player1', foreignKey: {allowNull: false}, onDelete: "RESTRICT" });
          Frame.belongsTo(models.Player, { as: 'Player2', foreignKey: {allowNull: false}, onDelete: "RESTRICT" });
        }
      }
    }
  )

  return Frame;
};
