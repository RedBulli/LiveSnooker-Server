module.exports = function(Sequelize, DataTypes) {
  var schema = {
    id: {
      primaryKey: true,
      type: DataTypes.UUID,
      defaultValue: DataTypes.UUIDV4
    },
    name: { type: DataTypes.STRING, allowNull: false }
  };
  var League = Sequelize.define("League", schema, {
      classMethods: {
        associate: function(models) {
          League.hasMany(models.User, { through: "Admins" });
          League.hasMany(models.Player);
        }
      }
    }
  )

  return League;
};
