module.exports = function(Sequelize, DataTypes) {
  var schema = {
    id: {
      primaryKey: true,
      type: DataTypes.UUID,
      defaultValue: DataTypes.UUIDV4
    },
    endedAt: {
      type: DataTypes.DATE
    }
  };
  var Frame = Sequelize.define("Frame", schema, {
      classMethods: {
        associate: function(models) {
          Frame.belongsTo(models.League, { foreignKey: {allowNull: false}, onDelete: "CASCADE" });
          Frame.belongsTo(models.Player, { as: 'Player1', foreignKey: {allowNull: false}, onDelete: "RESTRICT" });
          Frame.belongsTo(models.Player, { as: 'Player2', foreignKey: {allowNull: false}, onDelete: "RESTRICT" });
          Frame.belongsTo(models.Player, { as: 'Winner', foreignKey: {allowNull: true}, onDelete: "RESTRICT" });
          Frame.hasMany(models.Shot, { onDelete: "CASCADE" });
        }
      }
    }
  );

  return Frame;
};
