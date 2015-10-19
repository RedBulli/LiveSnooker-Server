module.exports = function(Sequelize, DataTypes) {
  var schema = {
    write: { type: DataTypes.BOOLEAN, allowNull: false, defaultValue: true }
  };
  var Admin = Sequelize.define("Admin", schema, {
    classMethods: {
      associate: function(models) {
        Admin.belongsTo(models.League, { foreignKey: {allowNull: false}, onDelete: "CASCADE" });
      }
    }
  });
  return Admin;
};
